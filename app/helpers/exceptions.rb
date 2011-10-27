module Exceptions

  RESULTS_THRESHOLD = 100000

  class ResultsTooBigError < StandardError
    Rails.logger.debug "ResultsTooBigError raised!."
  end
end