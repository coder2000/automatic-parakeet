class DownloadLinkDomainValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank? || record.file.attached?

    host = extract_host(value)
    unless host
      record.errors.add(attribute, "is invalid")
      return
    end

    exclusions = load_exclusions
    if exclusions.any? { |d| domain_match?(host, d) }
      record.errors.add(attribute, "domain is not permitted")
      return
    end

    allowed = load_allowed
    if allowed.any? && !allowed.any? { |d| domain_match?(host, d) }
      record.errors.add(attribute, "domain is not on the allowed list")
    end
  end

  private

  def extract_host(url)
    URI.parse(url).host&.downcase
  rescue URI::InvalidURIError
    nil
  end

  def load_exclusions
    Array(Rails.application.config_for(:download_links)["exclusions"]).map { |d| d.to_s.downcase }
  rescue
    []
  end

  def load_allowed
    ENV.fetch("ALLOWED_DOWNLOAD_HOSTS", "").split(",").map { |d| d.strip.downcase }.reject(&:blank?)
  end

  def domain_match?(host, domain)
    host == domain || host.end_with?(".#{domain}")
  end
end
