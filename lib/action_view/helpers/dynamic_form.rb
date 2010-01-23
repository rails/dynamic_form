# require 'cgi'
# require 'action_view/helpers/form_helper'
# require 'active_support/core_ext/class/attribute_accessors'
# require 'active_support/core_ext/enumerable'
# require 'active_support/core_ext/kernel/reporting'

module ActionView
  module Helpers
    module DynamicForm
      # Returns an entire form with all needed input tags for a specified Active Record object. For example, if <tt>@post</tt>
      # has attributes named +title+ of type +VARCHAR+ and +body+ of type +TEXT+ then
      #
      #   form("post")
      #
      # would yield a form like the following (modulus formatting):
      #
      #   <form action='/posts/create' method='post'>
      #     <p>
      #       <label for="post_title">Title</label><br />
      #       <input id="post_title" name="post[title]" size="30" type="text" value="Hello World" />
      #     </p>
      #     <p>
      #       <label for="post_body">Body</label><br />
      #       <textarea cols="40" id="post_body" name="post[body]" rows="20"></textarea>
      #     </p>
      #     <input name="commit" type="submit" value="Create" />
      #   </form>
      #
      # It's possible to specialize the form builder by using a different action name and by supplying another
      # block renderer. For example, if <tt>@entry</tt> has an attribute +message+ of type +VARCHAR+ then
      #
      #   form("entry",
      #     :action => "sign",
      #     :input_block => Proc.new { |record, column|
      #       "#{column.human_name}: #{input(record, column.name)}<br />"
      #   })
      #
      # would yield a form like the following (modulus formatting):
      #
      #   <form action="/entries/sign" method="post">
      #     Message:
      #     <input id="entry_message" name="entry[message]" size="30" type="text" /><br />
      #     <input name="commit" type="submit" value="Sign" />
      #   </form>
      #
      # It's also possible to add additional content to the form by giving it a block, such as:
      #
      #   form("entry", :action => "sign") do |form|
      #     form << content_tag("b", "Department")
      #     form << collection_select("department", "id", @departments, "id", "name")
      #   end
      #
      # The following options are available:
      #
      # * <tt>:action</tt> - The action used when submitting the form (default: +create+ if a new record, otherwise +update+).
      # * <tt>:input_block</tt> - Specialize the output using a different block, see above.
      # * <tt>:method</tt> - The method used when submitting the form (default: +post+).
      # * <tt>:multipart</tt> - Whether to change the enctype of the form to "multipart/form-data", used when uploading a file (default: +false+).
      # * <tt>:submit_value</tt> - The text of the submit button (default: "Create" if a new record, otherwise "Update").
      def form(record_name, options = {})
        record = instance_variable_get("@#{record_name}")
        record = convert_to_model(record)

        options = options.symbolize_keys
        options[:action] ||= record.new_record? ? "create" : "update"
        action = url_for(:action => options[:action], :id => record)

        submit_value = options[:submit_value] || options[:action].gsub(/[^\w]/, '').capitalize

        contents = form_tag({:action => action}, :method =>(options[:method] || 'post'), :enctype => options[:multipart] ? 'multipart/form-data': nil)
        contents << hidden_field(record_name, :id) unless record.new_record?
        contents << all_input_tags(record, record_name, options)
        yield contents if block_given?
        contents << submit_tag(submit_value)
        contents << '</form>'
        contents.html_safe!
      end
    end
  end
end

module ActionView
  module Helpers
    include DynamicForm
  end
end