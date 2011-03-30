module TableFormBuilderHelper
  include ERB::Util

  def table_field_row(type, field_name, label, field_html, options = {})
    raw <<-HTML
      <div class="row #{field_name} #{type}">
        <div class="cell label#{cell_classes(:label_class, options)}">
          #{label}
        </div>
        <div class="cell field #{cell_classes(:field_class, options)}">
          #{field_html}
        </div>
      </div>
    HTML
  end

  def table_submit_row(button_html)
    raw <<-HTML
      <div class="row commit">
        <div class="cell"></div>
        <div class="cell">
          #{button_html}
        </div>
      </div>
    HTML
  end

  def cell_classes(class_key, options)
    options[class_key].nil? ? nil : " #{options[class_key]}"
  end

  def raw(html)
    html.html_safe
  end

end

class TableFormBuilder < ActionView::Helpers::FormBuilder
  include TableFormBuilderHelper

  def field_settings(field, options = {}, tag_value = nil)
    field_name  = field.to_s
    label       = default_label(field, options)

    options[:class] ||= ""

    [field_name, label, options]
  end

  def text_field(field, options = {})
    field_name, label, options = field_settings(field, options)
    table_field_row("text", field_name, label, super, options)
  end

  def select(field, choices, options = {}, html_options = {})
    field_name, label, options = field_settings(field, options.merge(html_options))
    table_field_row("select", field_name, label, super, options)
  end

  def text_area(field, options = {})
    field_name, label, options = field_settings(field, options)
    table_field_row("text_area", field_name, label, super, options)
  end

  def default_label(field, options = {})
    label_for = options[:id] || "#{@object_name}_#{field}"
    label_id = "#{label_for}_label"
    label(field,
          options[:label],
          :for => label_for,
          :id => label_id,
          :class => "#{field}_label")
  end

end

module TableFormHelper
  include TableFormBuilderHelper

  def table_form_for(record_or_name_or_array, *args, &proc)
    options = args.detect { |argument| argument.is_a?(Hash) }

    if options.nil?
      options = {}
      args << options
    end

    options[:html] ||= {}
    options[:html][:class] ||= ""
    options[:builder] = TableFormBuilder

    form_for(record_or_name_or_array, *args, &proc)
  end

end