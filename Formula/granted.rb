class Granted < Formula
  desc "Grant matching tool for finding funding opportunities"
  homepage "https://github.com/KurtLehnardt/granted"
  url "https://github.com/KurtLehnardt/granted.git",
      tag:    "v1.0.1",
      branch: "main"
  version "1.0.1"
  license "MIT"

  depends_on "node@22" => :build

  def install
    # Navigate to the scaffold directory where package.json lives
    cd "scaffold"

    # Install dependencies from the lock file (reproducible)
    system "npm", "ci", "--omit=dev"

    # Build the Next.js application
    system "npm", "run", "build"

    # Install the entire app to libexec (Homebrew's standard directory for managed apps)
    # This includes .next, public, node_modules, all source files, and config
    libexec.install Dir["*"]

    # Create a simple executable wrapper
    (bin/"granted").write_env_script libexec/"start.sh",
      PATH: "#{libexec}/node_modules/.bin:$PATH"

    # Create the actual startup script
    (libexec/"start.sh").write <<~EOS
      #!/bin/bash
      cd #{libexec}
      PORT=3000 npx next start -H 127.0.0.1
    EOS
    (libexec/"start.sh").chmod 0755
  end

  def post_install
    puts "✓ Granted installed via Homebrew"
    puts ""
    puts "Note: For the full experience (auto-update, menu bar integration),"
    puts "consider using the native installers from:"
    puts "  https://github.com/KurtLehnardt/granted/releases"
    puts ""
    puts "To start Granted:"
    puts "  granted"
    puts ""
    puts "Then open your browser to: http://localhost:3000"
  end

  test do
    assert_predicate libexec/".next", :exist?
    assert_predicate libexec/"node_modules", :exist?
  end
end
