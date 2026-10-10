class Granted < Formula
  desc "Grant matching tool for finding funding opportunities"
  homepage "https://github.com/KurtLehnardt/granted"
  url "https://github.com/KurtLehnardt/granted.git",
      tag:    "v1.0.2",
      branch: "main"
  license "MIT"

  depends_on "node@22" => :build

  def install
    scaffold_dir = buildpath/"scaffold"

    # Build from the scaffold directory
    cd scaffold_dir

    # Install dependencies
    system "npm", "ci"

    # Install the entire scaffold directory (including dotfiles like .next,
    # if present) to libexec, excluding "." and "..".
    dot_skip = [".", ".."]
    dotfiles = Dir["#{scaffold_dir}/.*"].reject { |p| dot_skip.include?(File.basename(p)) }
    libexec.install Dir["#{scaffold_dir}/*"], dotfiles

    # Create an executable wrapper that auto-picks a free port, starting at
    # 3000 (or wherever PORT points, if the user set one), so a user never
    # has to pass a port in manually. `npm run dev` already passes
    # -H 127.0.0.1 (scaffold/package.json), so the wrapper just needs to
    # land on a free PORT before exec'ing it.
    (bin/"granted").write <<~EOS
      #!/bin/bash
      export PATH="#{libexec}/node_modules/.bin:$PATH"
      cd #{libexec}

      port="${PORT:-3000}"
      while (exec 3<>"/dev/tcp/127.0.0.1/$port") 2>/dev/null; do
        exec 3>&- 2>/dev/null
        port=$((port + 1))
      done
      export PORT="$port"

      echo "Starting Granted on http://127.0.0.1:$PORT"
      exec npm run dev
    EOS
    (bin/"granted").chmod 0755
  end

  def caveats
    <<~EOS
      For the full experience (auto-update, menu bar integration), consider
      using the native installers from:
        https://github.com/KurtLehnardt/granted/releases

      To start Granted:
        granted

      It automatically picks a free port starting at 3000 and prints the
      URL to open once it's ready.
    EOS
  end

  test do
    assert_path_exists libexec/"node_modules"
    assert_path_exists libexec/"package.json"
  end
end
