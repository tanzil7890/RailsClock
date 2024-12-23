module RailsClocks
  module ApplicationHelper
    def format_duration(duration)
      return '-' unless duration
      "#{duration.round(2)}ms"
    end

    def status_badge(status_code)
      class_name = case status_code.to_i
        when 200..299 then 'success'
        when 300..399 then 'info'
        when 400..499 then 'warning'
        when 500..599 then 'danger'
        else 'secondary'
      end

      content_tag :span, status_code, class: "badge badge-#{class_name}"
    end

    def format_timestamp(timestamp)
      return '-' unless timestamp
      timestamp.strftime('%Y-%m-%d %H:%M:%S')
    end

    def method_badge(method)
      class_name = case method.to_s.upcase
        when 'GET'    then 'primary'
        when 'POST'   then 'success'
        when 'PUT'    then 'info'
        when 'PATCH'  then 'info'
        when 'DELETE' then 'danger'
        else 'secondary'
      end

      content_tag :span, method.to_s.upcase, class: "badge badge-#{class_name}"
    end
  end
end
