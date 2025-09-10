# GRPC-client

GRPC-client is a tool similar to Postman, designed to interact with gRPC servers. It allows users to get gRPC reflections and responses from gRPC servers.

## Functionality

- **gRPC Reflection**: Fetches the gRPC reflection service and functions from the gRPC server.
- **gRPC Response**: Sends requests to the gRPC server and retrieves responses.

## Setup Process

1. **Clone the Repository**:
    ```sh
    brew tap bhagwati-web/grpc-client
    brew install grpc-client
    ```

2. **Run the Application**:
    Once everything good with above two command, you can start the application
    ```sh
    grpcstart
    ```

3. **Access the Application**:
    It should Open your browser automatically, if not, please navigate to `http://localhost:50051` to access the application.

4. Stop the application
    Simple close the terminal where you have started the `grpc-start` command. If you see that application still running in background after closing the terminal, simply run the following command from terminal. 
    ```sh
    grpcstop
    ```
5. **To Upgrade**:
   ```sh
    brew upgrade
    ```
   If above upgrade doesn't work then completly uninstall it first.  
    ```sh
    brew uninstall grpc-client
    brew untap bhagwati-web/grpc-client
    ```
    And then install it like step 1.

6. **Uninstallation**: 
   If you are not happy and having bad experience with tool, please report. To uninstall it run the following commands.  
    ```sh
    brew uninstall grpc-client
    brew untap bhagwati-web/grpc-client
    ```



## Additional Information

- **Frontend**: The frontend is built using React, TypeScript, and Vite.
- **Backend**: The backend is built using Spring Boot and Kotlin.
- **Configuration**: Update the configuration files as needed to match your environment.

