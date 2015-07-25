require "bundler/gem_tasks"

desc "Installs and build JRuby version of gem"
task :jinstall do
	if RUBY_PLATFORM == "java"
		Rake::Task["jbuild"].invoke
		file = Dir.glob("./pkg/*.gem").max_by { |f| File.mtime(f) }
		Gem.install file
	else
		system "jruby -S rake jinstall"
	end
end

desc "Builds JRuby version of gem"
task :jbuild do
	if RUBY_PLATFORM == "java"
		Rake::Task["build"].invoke
	else
		system "jruby -S rake jbuild"
	end
end