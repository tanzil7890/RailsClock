module RailsClocks
  class Sanitizer
    SENSITIVE_PATTERNS = [
      /password/i,
      /token/i,
      /secret/i,
      /credit_card/i,
      /ssn/i
    ]

    def self.sanitize_params(params)
      deep_transform(params) do |key, value|
        if sensitive_key?(key)
          '[FILTERED]'
        else
          value
        end
      end
    end

    private

    def self.sensitive_key?(key)
      SENSITIVE_PATTERNS.any? { |pattern| key.to_s =~ pattern }
    end
  end
end 