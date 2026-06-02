import os

# Create directory structure
directories = [
    'e:\\Projects\\synent-task8-mlmodel-abdelrahman\\notebooks',
    'e:\\Projects\\synent-task8-mlmodel-abdelrahman\\data',
    'e:\\Projects\\synent-task8-mlmodel-abdelrahman\\models',
    'e:\\Projects\\synent-task8-mlmodel-abdelrahman\\results',
    'e:\\Projects\\synent-task8-mlmodel-abdelrahman\\scripts'
]

for directory in directories:
    os.makedirs(directory, exist_ok=True)
    print(f'Created: {directory}')

print('Directory structure created successfully!')
