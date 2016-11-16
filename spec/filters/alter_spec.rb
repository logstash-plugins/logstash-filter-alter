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
      insist { subject.get("rewrite-me") } == "goodbye"
    end

    sample("rewrite-me"  => "greetings") do
      insist { subject.get("rewrite-me") } == "greetings"
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
      insist { subject.get("rewrite-me") } == "goodbye"
    end

    sample("rewrite-me"  => "hello") do
      insist { subject.get("rewrite-me") } == "hello"
    end

    sample("rewrite-me"  => "%{test}") do
      insist { subject.get("rewrite-me") } == "%{rewrite-value}"
    end

    sample("rewrite-me"  => "hello", "test" => "hello") do
      insist { subject.get("rewrite-me") } == "%{rewrite-value}"
    end

    sample("rewrite-me"  => "greetings", "test" => "hello") do
      insist { subject.get("rewrite-me") } == "greetings"
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
      insist { subject.get("rewrite-me") } == "goodbye"
    end

    sample("test-me"  => "hello", "rewrite-me"  => "hello2") do
      insist { subject.get("rewrite-me") } == "goodbye"
    end

    sample("test-me"  => "greetings") do
      insist { subject.get("rewrite-me") }.nil?
    end

    sample("test-me"  => "greetings",
      "rewrite-me"  => "hello2") do
      insist { subject.get("rewrite-me") } == "hello2"
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
      insist { subject.get("coalesce-me") } == "mydefault" 
    end
  end
end
