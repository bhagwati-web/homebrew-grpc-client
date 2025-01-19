class GrpcClient < Formula
  desc "Homebrew Package for a GRPC client to query the server"
  homepage "https://bhagwati-web.github.io/homebrew-grpc-client"
  
  version "1.2.1"
  jar_file = "grpc-client-#{version}.jar"
  sha256 "7a8f8710de5756c30d2ab7406fc295390e48aa1718cbb7f0966db5125f594286"
  server_port = "50051"
  server_url = "http://localhost:#{server_port}"

  url "https://github.com/bhagwati-web/grpc-client/releases/download/#{version}/#{jar_file}"
  sha256 sha256
  license "MIT"

  depends_on "openjdk@17"
  depends_on "grpcurl"

  def install
    libexec.install jar_file

    (bin/"grpcstart").write <<~EOS
      #!/bin/bash
      set -e

      # Set JAVA_HOME to use Java 17 installed via Homebrew
      export JAVA_HOME=$(/usr/libexec/java_home -v 17)
      export PATH=$JAVA_HOME/bin:$PATH

      # Start the GRPC client
      exec java -jar #{libexec}/#{jar_file} start "$@"
      
      # Allow time for the server to start
      sleep 5

      # Open the default browser with the server URL
      if command -v xdg-open > /dev/null; then
        xdg-open "#{server_url}"
      else
        open "#{server_url}"
      fi
    EOS

    (bin/"grpcstop").write <<~EOS
      #!/bin/bash
      set -e

      # Stop the GRPC client running on the specified port
      lsof -t -i:#{server_port} | xargs kill -9 "$@"
    EOS
  end
  
  def post_install
    puts <<~EOS
      \n\n\n\n========================================================
      GRPC Client installed successfully.
      Use 'grpcstart' to start the server and 'grpcstop' to stop it.
      The server will be available at #{server_url}, listening on port #{server_port}.
      ========================================================\n\n\n\n
    EOS
  end
end
