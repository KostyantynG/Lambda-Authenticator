import os
import json
import unittest
from unittest.mock import MagicMock, patch
from botocore.exceptions import ClientError
from src.lambda_authenticator.package.main import lambda_handler

class TestLambdaFunction(unittest.TestCase):
    def setUp(self):
        os.environ['AUTHENTICATOR_TABLE_NAME'] = 'fake_table'

    @patch('src.lambda_authenticator.package.main.get_dynamodb_table')
    def test_successful_authentication(self, mock_get_table):
        mock_table = MagicMock()
        mock_get_table.return_value = mock_table

        mock_table.get_item.return_value = {
            'Item': {
                'username': 'test_user',
                'password_hash': '$2b$12$PjYCl2j3uUI./JxmsfeV5.NrmFpRu3KQ93r7NtoK2Wd003KqLyqzO'
            }
        }

        auth_header = 'Basic dGVzdF91c2VyOnRlc3RfcGFzc3dvcmQ='
        event = {
            'headers': {
                'Authorization': auth_header
            }
        }

        response = lambda_handler(event, None)

        self.assertEqual(response['statusCode'], 200)
        self.assertEqual(json.loads(response['body']), "Authentication successful")

    @patch('src.lambda_authenticator.package.main.get_dynamodb_table')
    def test_dynamodb_error(self, mock_get_table):
        mock_table = MagicMock()
        mock_get_table.return_value = mock_table
        mock_table.get_item.side_effect = ClientError(
            error_response={'Error': {'Code': 'ResourceNotFoundException', 'Message': 'Requested resource not found'}},
            operation_name='GetItem'
        )

        auth_header = 'Basic dGVzdF91c2VyOnRlc3RfcGFzc3dvcmQ='
        event = {
            'headers': {
                'Authorization': auth_header
            }
        }

        response = lambda_handler(event, None)

        self.assertEqual(response['statusCode'], 503)
        self.assertIn('Service is currently unavailable. Please try again later.', json.loads(response['body']))

    @patch('src.lambda_authenticator.package.main.get_dynamodb_table')
    def test_invalid_authorization_header(self, mock_get_table):
        event = {
            'headers': {
                'Authorization': 'InvalidHeader'
            }
        }

        response = lambda_handler(event, None)

        self.assertEqual(response['statusCode'], 401)
        self.assertEqual(json.loads(response['body']), "Missing or invalid Authorization header")

    @patch('src.lambda_authenticator.package.main.get_dynamodb_table')
    def test_empty_username_password(self, mock_get_table):
        auth_header = 'Basic Og=='
        event = {
            'headers': {
                'Authorization': auth_header
            }
        }

        response = lambda_handler(event, None)

        self.assertEqual(response['statusCode'], 400)
        self.assertEqual(json.loads(response['body']), "Username or password cannot be empty")

    @patch('src.lambda_authenticator.package.main.get_dynamodb_table')
    def test_non_existent_user(self, mock_get_table):
        mock_table = MagicMock()
        mock_get_table.return_value = mock_table

        mock_table.get_item.return_value = {}

        auth_header = 'Basic bm9uX2V4aXN0ZW50OnBhc3N3b3Jk'
        event = {
            'headers': {
                'Authorization': auth_header
            }
        }

        response = lambda_handler(event, None)

        self.assertEqual(response['statusCode'], 403)
        self.assertEqual(json.loads(response['body']), "Invalid username or password")

    @patch('src.lambda_authenticator.package.main.get_dynamodb_table')
    def test_invalid_password(self, mock_get_table):
        mock_table = MagicMock()
        mock_get_table.return_value = mock_table
        
        mock_table.get_item.return_value = {
            'Item': {
                'username': 'test_user',
                'password_hash': '$2b$12$PjYCl2j3uUI./JxmsfeV5.NrmFpRu3KQ93r7NtoK2Wd003KqLyqzO'
            }
        }

        auth_header = 'Basic dGVzdF91c2VyOndyb25nX3Bhc3N3b3Jk'
        event = {
            'headers': {
                'Authorization': auth_header
            }
        }

        response = lambda_handler(event, None)

        self.assertEqual(response['statusCode'], 403)
        self.assertEqual(json.loads(response['body']), "Invalid username or password")

    def tearDown(self):
        del os.environ['AUTHENTICATOR_TABLE_NAME']

if __name__ == '__main__':
    unittest.main()
