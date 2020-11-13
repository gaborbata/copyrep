require 'test/unit'
require 'fileutils'

class TestHeaderReplace < Test::Unit::TestCase

  def setup
    FileUtils.rm_rf('test/actual')
    Dir.mkdir('test/actual')
    Dir.glob('test/examples/*').each do |example|
      FileUtils.cp(example, "test/actual/#{File.basename(example)}")
    end
  end

  def cleanup
    FileUtils.rm_rf('test/actual')
  end

  def test_copyrep
    eval ['ARGV = ["test/actual"]', File.read('copyrep.rb')].join("\n")
    Dir.glob('test/examples/*').each do |example|
      name = File.basename(example)
      expected = File.read("test/expected/#{name}")
      actual = File.read("test/actual/#{name}")
      assert_equal(expected, actual)
    end
  end

end
