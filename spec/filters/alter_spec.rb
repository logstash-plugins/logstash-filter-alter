# encoding: utf-8

require_relative '../spec_helper'
require "logstash/filters/alter"

def make_filter(config_hash)
  f = LogStash::Filters::Alter.new(config_hash)
  f.register
  f
end

def make_event(data)
  LogStash::Event.new(data)
end

describe LogStash::Filters::Alter do

  describe "condrewrite with static values" do
    let(:filter) { make_filter("condrewrite" => ["rewrite-me", "hello", "goodbye"]) }

    it "rewrites matching field" do
      event = make_event("rewrite-me" => "hello")
      filter.filter(event)
      expect(event.get("rewrite-me")).to eq("goodbye")
    end

    it "leaves non-matching field unchanged" do
      event = make_event("rewrite-me" => "greetings")
      filter.filter(event)
      expect(event.get("rewrite-me")).to eq("greetings")
    end
  end

  describe "condrewrite with dynamic values" do
    let(:filter) { make_filter("condrewrite" => ["rewrite-me", "%{test}", "%{rewrite-value}"]) }

    it "rewrites when field matches dynamic expected value" do
      event = make_event("rewrite-me" => "hello", "test" => "hello", "rewrite-value" => "goodbye")
      filter.filter(event)
      expect(event.get("rewrite-me")).to eq("goodbye")
    end

    it "leaves field unchanged when test field is absent" do
      event = make_event("rewrite-me" => "hello")
      filter.filter(event)
      expect(event.get("rewrite-me")).to eq("hello")
    end

    it "leaves field unchanged when value is literal %{test}" do
      event = make_event("rewrite-me" => "%{test}")
      filter.filter(event)
      expect(event.get("rewrite-me")).to eq("%{rewrite-value}")
    end

    it "leaves field unchanged when rewrite-value field is absent" do
      event = make_event("rewrite-me" => "hello", "test" => "hello")
      filter.filter(event)
      expect(event.get("rewrite-me")).to eq("%{rewrite-value}")
    end

    it "leaves non-matching field unchanged" do
      event = make_event("rewrite-me" => "greetings", "test" => "hello")
      filter.filter(event)
      expect(event.get("rewrite-me")).to eq("greetings")
    end
  end

  describe "condrewriteother" do
    let(:filter) { make_filter("condrewriteother" => ["test-me", "hello", "rewrite-me", "goodbye"]) }

    it "sets target field when source matches" do
      event = make_event("test-me" => "hello")
      filter.filter(event)
      expect(event.get("rewrite-me")).to eq("goodbye")
    end

    it "overwrites target field when source matches" do
      event = make_event("test-me" => "hello", "rewrite-me" => "hello2")
      filter.filter(event)
      expect(event.get("rewrite-me")).to eq("goodbye")
    end

    it "does not set target field when source does not match" do
      event = make_event("test-me" => "greetings")
      filter.filter(event)
      expect(event.get("rewrite-me")).to be_nil
    end

    it "leaves target field unchanged when source does not match" do
      event = make_event("test-me" => "greetings", "rewrite-me" => "hello2")
      filter.filter(event)
      expect(event.get("rewrite-me")).to eq("hello2")
    end
  end

  describe "coalesce" do
    let(:filter) { make_filter("coalesce" => ["coalesce-me", "%{non-existing-field}", "mydefault"]) }

    it "sets field to first non-null resolved value" do
      event = make_event("coalesce-me" => "Hello")
      filter.filter(event)
      expect(event.get("coalesce-me")).to eq("mydefault")
    end
  end
end

