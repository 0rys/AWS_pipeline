// Existing Terraform src code found at /tmp/terraform_src.

locals {
  stack_name = "EBS-infrastructure-copy"
}

variable python_version {
  description = "Python version to use"
  type = string
  default = "3.9"
}

variable repository_name {
  description = "Name of the RepositoryName"
  type = string
}

variable branch_name {
  description = "Name of the repo branch with the project"
  type = string
}

variable git_hub_owner {
  description = "Username of the owner of the github repository"
  type = string
}

variable git_hub_o_auth_token {
  description = "Authentication token to access github"
  type = string
}

resource "aws_elastic_beanstalk_application" "elastic_beanstalk_application" {
  name = "${local.stack_name}-app"
  description = "Application for the pipeline deployment"
}

resource "aws_elastic_beanstalk_environment" "elastic_beanstalk_environment" {
  application = aws_elastic_beanstalk_application.elastic_beanstalk_application.arn
  name = "${local.stack_name}-env"
  solution_stack_name = "64bit Amazon Linux 2023 v4.5.1 running Python 3.12"
  setting = [
    {
      Namespace = "aws:autoscaling:launchconfiguration"
      OptionName = "IamInstanceProfile"
      Value = aws_iam_instance_profile.instance_profile.arn
    },
    {
      Namespace = "aws:elasticbeanstalk:environment"
      OptionName = "ServiceRole"
      Value = aws_iam_role.eb_service_role.arn
    }
  ]
}

resource "aws_iam_role" "eb_service_role" {
  assume_role_policy = {
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "elasticbeanstalk.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  }
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkService",
    "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkEnhancedHealth"
  ]
}

resource "aws_iam_role" "eb_instance_role" {
  assume_role_policy = {
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  }
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier",
    "arn:aws:iam::aws:policy/AWSElasticBeanstalkMulticontainerDocker",
    "arn:aws:iam::aws:policy/AWSElasticBeanstalkWorkerTier"
  ]
}

resource "aws_iam_instance_profile" "instance_profile" {
  role = [
    aws_iam_role.eb_instance_role.arn
  ]
}

resource "aws_datapipeline_pipeline" "pipeline" {
  name = "${local.stack_name}-pipeline"
  // CF Property(RoleArn) = aws_iam_role.codepipeline_service_role.arn
  // CF Property(ArtifactStore) = {
  //   Type = "S3"
  //   Location = "artifactbucket363757"
  // }
  tags = [
    {
      Name = "Source"
      Actions = [
        {
          Name = "Source"
          ActionTypeId = {
            Category = "Source"
            Owner = "ThirdParty"
            Provider = "GitHub"
            Version = "1"
          }
          Configuration = {
            Owner = var.git_hub_owner
            Repo = var.repository_name
            Branch = var.branch_name
            OAuthToken = var.git_hub_o_auth_token
          }
          OutputArtifacts = [
            {
              Name = "SourceOutput"
            }
          ]
          RunOrder = 1
        }
      ]
    },
    {
      Name = "Build"
      Actions = [
        {
          Name = "Build"
          ActionTypeId = {
            Category = "Build"
            Owner = "AWS"
            Provider = "CodeBuild"
            Version = "1"
          }
          Configuration = {
            ProjectName = aws_codebuild_project.build_project.arn
          }
          InputArtifacts = [
            {
              Name = "SourceOutput"
            }
          ]
          OutputArtifacts = [
            {
              Name = "BuildOutput"
            }
          ]
          RunOrder = 1
        }
      ]
    },
    {
      Name = "Test"
      Actions = [
        {
          Name = "Test"
          ActionTypeId = {
            Category = "Test"
            Owner = "AWS"
            Provider = "CodeBuild"
            Version = "1"
          }
          Configuration = {
            ProjectName = aws_codebuild_project.test_project.arn
          }
          InputArtifacts = [
            {
              Name = "SourceOutput"
            }
          ]
          RunOrder = 1
        }
      ]
    },
    {
      Name = "Deploy"
      Actions = [
        {
          Name = "Deploy"
          ActionTypeId = {
            Category = "Deploy"
            Owner = "AWS"
            Provider = "ElasticBeanstalk"
            Version = "1"
          }
          Configuration = {
            ApplicationName = aws_elastic_beanstalk_application.elastic_beanstalk_application.arn
            EnvironmentName = aws_elastic_beanstalk_environment.elastic_beanstalk_environment.id
          }
          InputArtifacts = [
            {
              Name = "BuildOutput"
            }
          ]
          RunOrder = 1
        }
      ]
    }
  ]
}

resource "aws_s3_bucket" "artifactbucket363757" {
  bucket = "artifactbucket363757"
  versioning {
    // CF Property(Status) = "Enabled"
  }
}

resource "aws_iam_role" "code_build_service_role" {
  assume_role_policy = {
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  }
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AWSCodeBuildAdminAccess",
    "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  ]
}

resource "aws_iam_role" "codepipeline_service_role" {
  assume_role_policy = {
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "codepipeline.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  }
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AWSCodePipeline_FullAccess",
    "arn:aws:iam::aws:policy/AWSCodeBuildAdminAccess",
    "arn:aws:iam::aws:policy/AdministratorAccess-AWSElasticBeanstalk"
  ]
}

resource "aws_codebuild_project" "build_project" {
  name = "${local.stack_name}-build"
  service_role = aws_iam_role.code_build_service_role.arn
  artifacts {
    type = "CODEPIPELINE"
  }
  environment {
    type = "LINUX_CONTAINER"
    compute_type = "BUILD_GENERAL1_SMALL"
    image = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
    environment_variable = [
      {
        Name = "PYTHON_VERSION"
        Value = var.python_version
      }
    ]
  }
  source {
    type = "CODEPIPELINE"
    buildspec = "buildspec.yml"
  }
}

resource "aws_codebuild_project" "test_project" {
  name = "${local.stack_name}-test"
  service_role = aws_iam_role.code_build_service_role.arn
  artifacts {
    type = "CODEPIPELINE"
  }
  environment {
    type = "LINUX_CONTAINER"
    compute_type = "BUILD_GENERAL1_SMALL"
    image = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
    environment_variable = [
      {
        Name = "PYTHON_VERSION"
        Value = var.python_version
      }
    ]
  }
  source {
    type = "CODEPIPELINE"
    buildspec = "testspec.yml"
  }
}

resource "aws_codebuild_project" "deploy_project" {
  name = "${local.stack_name}-deploy"
  service_role = aws_iam_role.code_build_service_role.arn
  artifacts {
    type = "CODEPIPELINE"
  }
  environment {
    type = "LINUX_CONTAINER"
    compute_type = "BUILD_GENERAL1_SMALL"
    image = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
    environment_variable = [
      {
        Name = "PYTHON_VERSION"
        Value = var.python_version
      }
    ]
  }
  source {
    type = "CODEPIPELINE"
    buildspec = "deployspec.yml"
  }
}

output "build_project_name" {
  description = "Name of the build project"
  value = aws_codebuild_project.build_project.arn
}
