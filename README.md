# Authenticator Lambda

This repository contains an implementation of an AWS Lambda function for user authentication via a simple API Gateway.

## Prerequisites

Before deploying and running the solution, ensure you have the following tools installed:

1. **Python3.12**: Python interpreter for running scripts.
   - Installation instructions can be found on the [Python website](https://www.python.org/downloads).

1. **Terraform**: Infrastructure as Code tool.
   - Installation instructions can be found on the [Terraform website](https://www.terraform.io/downloads.html).

1. **AWS CLI**: Command Line Interface for AWS.
   - Installation instructions can be found on the [AWS CLI User Guide](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html).

1. **Task**: Task automation tool.
   - Install Task using the instructions from the [Task documentation](https://taskfile.dev/installation/#installation).

1. **cURL**: Command line tool for making HTTP requests.
   - cURL is typically pre-installed on macOS and Linux. For Windows, you can follow [these instructions](https://curl.se/windows/).

## Note
Make sure you have AWS credentials configured in your environment for the AWS CLI to interact with your AWS account. You can configure your credentials using the following command:

```bash
aws configure
```

## Setting Up the Project
### Initialize
After cloning this repository, navigate to the project directory and run the following command to initialize the Terraform project:

```bash
task init
```


### Plan
To make a dry-run deployment, use following command:

```bash
task plan
```
This command will prompt you for AWS account id and AWS region


### Deploy
To deploy the solution, run:

```bash
task deploy
```
This command will prompt you for AWS account id and AWS region

``` Make sure to save the value of Lamdba invoke URL from the output ```

### Switching Backend to Remote (Optional)
After deploying the solution, you can optionally switch your Terraform state backend to a remote backend (S3). This is useful for team collaboration or managing Terraform state across environments.

To switch the backend, use the following command:

```bash
task switch_backend
```

This command will configure the remote backend to pre-deployed S3 bucket. State lock will be configured in pre-deployed DynamoDB table. Once complete, your Terraform state will be stored remotely.

### Setting up the virtual environment
In order to run Authenticator Lambda locally you have to create virtual environment first. Do it using following command:

```bash
task setup_venv
```

### Populating DynamoDB table with test users
In order to use the Authenticator Lambda we need to create a record in DynamoDB table. To do that we use following command:

```bash
task create_user
```

It will prompt you for `username` and `password` (choose any)

<br>

## Running the solution
To invoke the Authenticator Lambda, use following command:

```bash
task run
```

This command will prompt you for the Lamdba invoke URL, `username` and `password` (input the same values you used during `create_user` task command)

<br>

## Testing Lambda locally
### Running unit tests on Authenticator Lambda locally
After virtual environment is created, you can run tests locally. to do that, use following command:

```bash
task local_test
```

<br>

## Running Authenticator Lambda using swagger
In order to run solution using Open API documentation, you can use `swagger.yaml` file, located in root folder. Import it to [swagger.io](https://editor.swagger.io/) website and perform following steps:

1. Configure Computed URL value.

   - fill up `api_id` field - an id of you API Gateway deployment, which is also a part of Invoke URL from `task deploy` command output
   - fill up `region` field - AWS region you deployed the solution to

   After these 2 fields are filled up, Computed URL value has to be identical to Invoke URL from `task deploy` command output

2. Authorize

   Use button `Authorize` and provide `username` and `password`

3. Run the solution

   Use `Try it out` and `Execute` buttons to send the request to our API



