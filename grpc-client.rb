class GrpcClient < Formula
  desc "Homebrew Package for a GRPC client to query the server"
  homepage "https://bhagwati-web.github.io/homebrew-grpc-client"
  
  version "1.2.1"
  @@jar_file = "grpc-client-#{version}.jar"
  @@sha256 = "7a8f8710de5756c30d2ab7406fc295390e48aa1718cbb7f0966db5125f594286"
  @@server_port = "50051"
  @@server_url = "http://localhost:#{@@server_port}"

  url "https://github.com/bhagwati-web/grpc-client/releases/download/#{version}/#{@@jar_file}"
  sha256 @@sha256
  license "MIT"

  depends_on "openjdk@17"
  depends_on "grpcurl"

  def install
    libexec.install @@jar_file
    (bin/"grpcstart").write <<~EOS
      #!/bin/bash

      # Start the GRPC client
      exec java -jar #{libexec}/#{@@jar_file} start "$@"
      
      # Allow time for the server to start
      sleep 5

      # Open the default browser with the server URL
      if command -v xdg-open > /dev/null; then
        xdg-open "#{@@server_url}"
      else
        open "#{@@server_url}"
      fi
    EOS
    (bin/"grpcstop").write <<~EOS
      #!/bin/bash
      exec lsof -t -i:#{@@server_port} | xargs kill -9 "$@"
    EOS
  end
  
  def post_install
    puts "\n\n\n================================================"
    puts "GRPC Client installed. Use 'grpcstart' and 'grpcstop' to manage the server."
    puts "If this doesn't work, please switch to Java 17 and try again running the above command."
    puts "The server will be available on #{@@server_url} and listening on port #{@@server_port}."
    puts "================================================\n\n\n"
  end
end
