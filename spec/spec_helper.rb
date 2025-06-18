# frozen_string_literal: true

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  RSpec::Matchers.define :be_within_a_cent_of do |expected|
    match { |actual| (actual - expected).abs < 0.01 }
    failure_message do |actual|
      "expected that #{actual} would be within 0.01 of #{expected}"
    end
  end
end
