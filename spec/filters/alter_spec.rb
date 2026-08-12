# encoding: utf-8

require_relative '../spec_helper'
require "logstash/filters/alter"

describe LogStash::Filters::Alter do

  describe "condrewrite with static values" do
    config <<-CONFIG
    filter {
      alter {
        condrewrite => ["rewrite-me", "hello", "goodbye"]
      }
    }
    CONFIG

    sample("rewrite-me"  => "hello") do
      expect(subject.get("rewrite-me")).to eq("goodbye")
    end

    sample("rewrite-me"  => "greetings") do
      expect(subject.get("rewrite-me")).to eq("greetings")
    end
  end

  describe "condrewrite with dynamic values" do
    config <<-CONFIG
    filter {
      alter {
        condrewrite => ["rewrite-me", "%{test}", "%{rewrite-value}"]
      }
    }
    CONFIG

    sample("rewrite-me"  => "hello", "test" => "hello",
           "rewrite-value" => "goodbye") do
      expect(subject.get("rewrite-me")).to eq("goodbye")
    end

    sample("rewrite-me"  => "hello") do
      expect(subject.get("rewrite-me")).to eq("hello")
    end

    sample("rewrite-me"  => "%{test}") do
      expect(subject.get("rewrite-me")).to eq("%{rewrite-value}")
    end

    sample("rewrite-me"  => "hello", "test" => "hello") do
      expect(subject.get("rewrite-me")).to eq("%{rewrite-value}")
    end

    sample("rewrite-me"  => "greetings", "test" => "hello") do
      expect(subject.get("rewrite-me")).to eq("greetings")
    end
  end

  describe "condrewriteother" do
    config <<-CONFIG
    filter {
      alter {
        condrewriteother => ["test-me", "hello", "rewrite-me","goodbye"]
      }
    }
    CONFIG

    sample("test-me"  => "hello") do
      expect(subject.get("rewrite-me")).to eq("goodbye")
    end

    sample("test-me"  => "hello", "rewrite-me"  => "hello2") do
      expect(subject.get("rewrite-me")).to eq("goodbye")
    end

    sample("test-me"  => "greetings") do
      expect(subject.get("rewrite-me")).to be_nil
    end

    sample("test-me"  => "greetings",
      "rewrite-me"  => "hello2") do
      expect(subject.get("rewrite-me")).to eq("hello2")
    end
  end

  describe "coalesce" do
    config <<-CONFIG
    filter {
      alter {
        coalesce => ["coalesce-me", "%{non-existing-field}", "mydefault"]
      }
    }
    CONFIG

    sample("coalesce-me"  => "Hello") do
      expect(subject.get("coalesce-me")).to eq("mydefault")
    end
  end
end
