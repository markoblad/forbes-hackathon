module ApplicationHelper
    
 
  def urlify(string)
    return string.rstrip.gsub(/ /,'-').gsub(/[^[:alnum:]^-]/, '').downcase
  end

  def rand_by_length(length)
    rand((9.to_s * length).to_i).to_s.center(length, rand(9).to_s).to_s
  end

  def open_tag(tag, attr = {}, indent = '', self_close = false)
    attributes = ""
    inner = ""
    attr.each {|key,val|
      if (['class', 'id', 'style', 'name', 'content', 'property', 'http-equiv', 'charset', 'href', 'title', 'target', 'src', 'width', 'height', 'alt', 'rel', 'sizes', 'data-animation', 'data-control'].include?(key))
        attributes = attributes + ' ' + key + '="' + parse_dynamic_string(val) + '"'
      elsif (key == 'nested')
        for nested in val
          inner = inner + open_tag(tag, nested, indent)
        end
      end
    }
    if (self_close)
      return indent + '<' + tag + attributes + ' />' + "\n"
    else
      return indent + '<' + tag + attributes + '>' + "\n" + inner
    end
  end
  
  def close_tag(tag, attr = {}, indent = '')
    id = ""
    inner = ""
    if (attr['id'])
      id = attr['id']
    end
    if attr['nested']
      for nested in attr['nested']
        inner = close_tag(tag, nested, indent) + inner
      end
    end
    return inner + indent + '</div>' + "\n"
  end

  def show_meta(tags)
    if tags
      for tag in tags
        tag['conditions'] ||= {}
        if test_conditions(tag['conditions'])
          concat raw open_tag('meta', tag)
        end
      end
    end
  end
  
  def show_scripts(scripts, in_footer = false)
    if scripts
      for script in scripts
        script['conditions'] ||= {}
        if test_conditions(script['conditions'])
          if (script['in_footer'] === in_footer)
            if script['content']
              concat raw '<script type="text/javascript">' + script['content'] + '</script>' + "\n"
            elsif script['url']
              concat raw '<script type="text/javascript" src="' + script['url'] + '"></script>' + "\n"
            elsif script['name']
              concat javascript_include_tag script['name']
              concat raw "\n"
            end
          end
        end
      end
    end
  end
  
  def show_styles(styles, in_footer = false)
    if styles
      for style in styles
        style['conditions'] ||= {}
        if test_conditions(style['conditions'])
          if (style['in_footer'] === in_footer)
            if style['content']
              concat raw '<style type="text/css">' + style['content'] + '</style>' + "\n"
            elsif style['url']
              concat raw '<link href="' + style['url'] + '?theme=' + @theme.slug + '&palette=' + @palette.id.to_s + '" media="' + style['media'] + '" rel="stylesheet" type="text/css" />' + "\n"
            elsif style['name']
              concat stylesheet_link_tag style['name'], :media => style['media']
              concat raw "\n"
            end
          end
        end
      end
    end
  end
  
  def show_palette
    concat raw '<link href="/builder/palettes/' + @palette.id.to_s + '.css?theme_id=' + @theme.id.to_s + '" media="all" rel="stylesheet" type="text/css" />' + "\n"
  end
  
  def show_favicons(favicons)
    if favicons
      for favicon in favicons
        favicon['conditions'] ||= {}
        if test_conditions(favicon['conditions'])
          concat raw open_tag('link', favicon)
        end
      end
    end
  end
  
  def show_matrix(matrix, tag = 'div', indent = "\t")
    matrix['conditions'] ||= {}
    if matrix && test_conditions(matrix['conditions'])
      concat raw open_tag(tag, matrix, indent)
      if matrix['call']
        parse_template_call(matrix['call'])
      end
      if matrix['html']
        concat raw matrix['html']
      elsif (matrix['template'])
        concat render :partial => "#{matrix['template']}", :locals => { :page => @page, :site => @site, :vars => matrix}
      elsif matrix['rows']
        for row in matrix['rows']
          row['conditions'] ||= {}
          if test_conditions(row['conditions'])
            concat raw open_tag(tag, row, indent+"\t")
            if row['call']
              parse_template_call(row['call'])
            end
            if row['html']
              concat raw row['html']
            elsif (row['template'])
              concat render :partial => "#{row['template']}", :locals => { :page => @page, :site => @site, :vars => row}
            elsif (row['cols'])
              for col in row['cols']
                col['conditions'] ||= {}
                if test_conditions(col['conditions'])
                  if (col['rows'])
                    show_matrix(col, tag, indent+"\t\t\t")
                  else
                    concat raw open_tag(tag, col, indent+"\t\t")
                    if col['call']
                      parse_template_call(col['call'])
                    end
                    if col['html']
                      concat raw col['html']
                    elsif (col['template'])
                      concat render :partial => "#{col['template']}", :locals => { :page => @page, :site => @site, :vars => col}
                    end
                    concat raw close_tag(tag, col, indent+"\t\t");
                  end
                end
              end
            end
            concat raw close_tag(tag, row, indent+"\t");
          end
        end
      end
      concat raw close_tag(tag, matrix, indent)
      concat raw "\n\n"
    end
  end
  
  def show_title
    if !@meta_title.blank?
      concat raw '<title>' + @meta_title + '</title>' + "\n"
    elsif @is_homepage
      concat raw '<title>' + @title + ' | ' + parse_dynamic_string(Settings.sites.defaults.homepage.title.suffix) + '</title>' + "\n"
    else
      concat raw '<title>' + @title + ' | ' + parse_dynamic_string(Settings.sites.defaults.page.title.suffix) + '</title>' + "\n"
    end
  end

  def show_description
    content = ""
    if !@meta_description.blank?
      content = @meta_description
    elsif @is_homepage
      content = @site.blurb_a
    end
    concat raw '<meta name="description" content="' + content.to_s + '">' + "\n"
  end
  
  def show_robots
    mi = "no" if !@meta_index
    mf = "no" if !@meta_follow
    concat raw '<meta name="robots" content="' + mi.to_s + 'index, ' + mf.to_s + 'follow">' + "\n"
  end

  def show_analytics
    if ENV['ENV_SERVED'] == "production"
      ga_client = ''
      if @site.google_analytics_code && !@site.google_analytics_code.blank?
        ga_client = '
    _gaq.push(["_setAccount", "' + @site.google_analytics_code + '"]);
    _gaq.push(["_trackPageview"]);
  '
      end
      concat raw '  <script type="text/javascript">
    var _gaq = _gaq || [];
  ' + ga_client + '
    _gaq.push(["b._setAccount", "' + Settings.google.analytics.account + '"]);
    _gaq.push(["b._trackPageview"]);
  
    (function() {
      var ga = document.createElement("script"); ga.type = "text/javascript"; ga.async = true;
      ga.src = ("https:" == document.location.protocol ? "https://ssl" : "http://www") + ".google-analytics.com/ga.js";
      var s = document.getElementsByTagName("script")[0]; s.parentNode.insertBefore(ga, s);
    })();
    
    </script>
'
    end
  end

  
  def show_nine_slice
    concat raw '
<div class="top-left"></div>
<div class="top"></div>
<div class="top-right"></div>
<div class="left"></div>
<div class="middle"></div>
<div class="right"></div>
<div class="bottom-left"></div>
<div class="bottom"></div>
<div class="bottom-right"></div>
'
  end
  
  def show_layout(layout)
    if layout
      for div in layout
#         unless (@page && div['context'] == 'home' && !@is_homepage) || (@page && div['context'] == 'page' && @is_homepage) || (!@page && div['context'] == 'home')
        unless (div['controller'] && div['controller'] != controller_name) || (div['action'] && div['action'] != action_name) || (div['homepage'] != nil && div['homepage'] != @is_homepage)
          show_matrix(div)
        end
      end
    end
  end
  
  def show_fieldsets(form, fieldsets, &block)
    fieldsets.each do |fieldset|
      show_fieldset(form, fieldset)
    end
  end

  def show_fieldset(form, fieldset)
    fieldset['conditions'] ||= {}
    if test_conditions(fieldset.conditions)
      fieldset['attributes'] ||= {}
      fieldset['header'] ||= nil
      fieldset['footer'] ||= nil
      fieldset['template'] ||= nil
      fieldset['fields'] ||= {}
      fieldset['aside'] ||= nil
      attrStr = get_attribute_string(fieldset.attributes)
      concat raw '<div' + attrStr + '>'
      unless fieldset.header.nil?
        concat t(fieldset.header, :default => fieldset.header)
      end
      unless fieldset.aside.nil?
        concat raw '<div class="aside"><aside>'
        concat t(fieldset.aside, :default => fieldset.aside)
        concat raw '</aside></div>'
      end
      if fieldset.template.nil?
        concat raw '<fieldset>'
        show_fields(form, fieldset.fields)
        concat raw '</fieldset>'
      else
        concat render :partial => "#{fieldset.template}", :locals => {:form => form, :fields => fieldset.fields, :vars => fieldset}
      end
      unless fieldset.footer.nil?
        concat t(fieldset.footer, :default => fieldset.footer)
      end
      concat raw '</div>'
    end
  end
  
  def show_fields(form, fields)
    fields.each do |field|
      show_field(form, field)
    end
  end
  
  def show_field(form, field)
    field['conditions'] ||= {}
    if test_conditions(field.conditions)
      field['name'] ||= ''
      field['template'] ||= nil
      field['type'] ||= ''
      field['label'] ||= 'Missing label'
      field['placeholder'] ||= field['label']
      field['options'] ||= {}
      field['html_options'] ||= {}
      field['value'] ||= ''
      field['cssClass'] ||= ''
      field['attributes'] ||= {}
      concat raw '<div class="' + field.name + ' field ' + field.type + '" id="field-' + field.name + '">'
      name = field.name.to_sym
      label = t(field.label, :default => field.label)
      placeholder = t(field.placeholder, :default => field.placeholder)
      value = field.value
      options = field.options
      html_options = field.html_options
      attributes = field.attributes
      attrStr = get_attribute_string(attributes)
      cssClass = field.cssClass
      #attributes.merge!(:value => value)
      attributes.merge!(:placeholder => placeholder)
      attributes.merge!(:class => cssClass)
      if field.template.nil?
        if form.nil?
          case field.type
          when 'link'
            concat raw '<a ' + attrStr + '>'+label+'</a>'
          when 'page_link'
            concat raw '<a href="' + @site.local_url+@page.url + '" ' + attrStr + '>'+label+'</a>'
          when 'button_tag'
            attrStr += ' class="' + cssClass + '"'
            concat raw '<button type="button" role="button" ' + attrStr + '>'+label+'</button>'
          when 'text_field'
            concat raw label_tag(name, label, :class => 'field-label')
            attrStr += ' class="' + cssClass + '"'
            concat raw '<input type="text" id="' + name.to_s + '" name="' + name.to_s + '" placeholder="' + placeholder + '" value="' + value + '"' + attrStr + '>'
#             if value.empty?
#               concat raw text_field_tag(name, value, :placeholder => placeholder, :class => cssClass)
#             else
#               concat raw text_field_tag(name, value, :placeholder => placeholder, :class => cssClass)
#             end
          when 'email_field'
            concat raw label_tag(name, label, :class => 'field-label')
            concat raw email_field_tag(name, value, :placeholder => placeholder, :class => cssClass)
          when 'text_area'
            concat raw label_tag(name, label, :class => 'field-label')
            concat raw text_area_tag(name, value, :placeholder => placeholder, :class => cssClass)
          when 'affiliate_tag'
            if request.env['affiliate.tag']
              concat raw hidden_field_tag(name, :value => request.env['affiliate.tag'])
            end
          when 'submit'
            concat raw submit_tag(label, :class => name.to_s)
          end    
        else
          case field.type
          when 'link'
            concat raw '<a ' + attrStr + '>'+label+'</a>'
          when 'page_link'
            concat raw '<a href="' + @site.local_url+@page.url + '" ' + attrStr + '>'+label+'</a>'
          when 'button_tag'
            attrStr += ' class="' + cssClass + '"'
            concat raw '<button type="button" role="button" ' + attrStr + '>'+label+'</button>'
          when 'link_to'
            #html_options.merge!({:class => cssClass})
            concat raw link_to(label, options, html_options)
          when 'button_to'
            #html_options = html_options.merge({'class' => 'alternate'})
            hash = {:class => cssClass}
            concat raw button_to(label, options, hash.merge(html_options))
          when 'text_field'
            concat raw form.label(name, label, :class => 'field-label')
            if value.empty?
              concat raw form.text_field(name, attributes)
            else
              concat raw form.text_field(name, :placeholder => placeholder, :value => value, :class => cssClass)
            end
          when 'email_field'
            #value = form.object.send(field.name) if value.empty?
            concat raw form.label(name, label, :class => 'field-label')
            concat raw form.email_field(name, attributes)
          when 'password_field'
            concat raw form.label(name, label, :class => 'field-label')
            concat raw form.password_field(name, :placeholder => placeholder, :class => cssClass)
          when 'text_area'
            concat raw form.label(name, label, :class => 'field-label')
            concat raw form.text_area(name, attributes)
          when 'file_field'
            concat raw form.label(name, label, :class => 'field-label')
            unless attributes['disabled'] == 'disabled'
              concat raw '<div class="file-inputs"><input type="text" class="dummy-input"><button type="button" role="button">' + t('application.forms.fields.file_upload.button_label') + '</button>' + form.file_field(name, attributes) + '</div>'
            else
              #concat raw '<div class="file-inputs">' + form.file_field(name, attributes) + '</div>'
              concat raw '<div class="file-inputs"><input type="text" class="dummy-input"' + attrStr + '><button type="button" role="button" ' + attrStr + '>' + t('application.forms.fields.file_upload.button_label') + '</button></div>'
            end
          when 'file_preview'
            delete_name = 'delete_' + name.to_s
            concat raw '<div class="file-preview"><img alt ="' + label + '" /><br />' + form.check_box(delete_name.to_sym) + ' Delete?</div>'
          when 'check_box'
            concat raw form.check_box(name, attributes) + ' ' + label
          when 'radio_button'
            concat raw form.radio_button(name, value, attributes) + ' ' + label
          when 'select'
            concat raw form.label(name, label, :class => 'field-label')
            concat raw form.select(name, options, :class => cssClass)
          when 'select_by_method'
            object = field.object.constantize
            method = field.method
            concat raw form.label(name, label, :class => 'field-label')
            concat raw form.select(name, object.send(method), :class => cssClass)
          when 'collection_select'
            args = []
            options.each do |option|
              case option[0]
              when '@'
                args << instance_variable_get(option) 
              when ':'
                option[0] = ''
                args << option.to_sym
              when '{'
                args << JSON.parse(option)
              else
                case option.class
                  when Symbol
                    args << option
                  when String
                    args << instance_variable_get(option)
                  else
                    args << option
                end
              end
            end
            concat raw form.label(name, label, :class => 'field-label')
            concat raw form.collection_select(name, args[0], args[1], args[2], args[3])
      #     when 'javascript_select'
      #       options.each do |option|
      #         concat raw '<div class="option" ' + attrStr + '>' + label + '</div>'
      #       end
          when 'hidden'
            concat raw form.hidden_field(name, :value => value)
          when 'submit'
            concat raw form.submit(label)
          when 'link_modal'
            concat raw '<a ' + attrStr + ' data-toggle="modal" data-dismiss="modal">' + label + '</a>'
          when 'button_modal'
            concat raw '<button href="#modal-' + name.to_s + '" ' + attrStr + ' data-toggle="modal" data-dismiss="modal">' + label + '</button>'
          when 'affiliate_tag'
            if request.env['affiliate.tag']
              concat raw form.hidden_field(name, :value => request.env['affiliate.tag'])
            end
          when 'palette_select'
            options = ''
            @palettes.each do |palette|
              options += "<li data-id='" + palette.id.to_s + "'><div class='palette'>
<div class='color color-a' style='background-color: ##{palette.color_a}'></div>
<div class='color color-b' style='background-color: ##{palette.color_b}'></div>
<div class='color color-c' style='background-color: ##{palette.color_c}'></div>
<div class='color color-d' style='background-color: ##{palette.color_d}'></div>
<div class='color color-e' style='background-color: ##{palette.color_e}'></div>
<div class='color neutral-5' style='background-color: ##{palette.neutral_5}'></div>
<div class='color neutral-4' style='background-color: ##{palette.neutral_4}'></div>
<div class='color neutral-3' style='background-color: ##{palette.neutral_3}'></div>
<div class='color neutral-2' style='background-color: ##{palette.neutral_2}'></div>
<div class='color neutral-1' style='background-color: ##{palette.neutral_1}'></div>
<div class='color neutral-0' style='background-color: ##{palette.neutral_0}'></div>
</div></li>"
            end
            concat raw form.label(name, label, :class => 'field-label')
            concat raw "<div id='palette-selector' class='dropdown'>
<a class='selection'><div class='palette'>
<div class='color color-a' style='background-color: ##{@palette.color_a}'></div>
<div class='color color-b' style='background-color: ##{@palette.color_b}'></div>
<div class='color color-c' style='background-color: ##{@palette.color_c}'></div>
<div class='color color-d' style='background-color: ##{@palette.color_d}'></div>
<div class='color color-e' style='background-color: ##{@palette.color_e}'></div>
<div class='color neutral-5' style='background-color: ##{@palette.neutral_5}'></div>
<div class='color neutral-4' style='background-color: ##{@palette.neutral_4}'></div>
<div class='color neutral-3' style='background-color: ##{@palette.neutral_3}'></div>
<div class='color neutral-2' style='background-color: ##{@palette.neutral_2}'></div>
<div class='color neutral-1' style='background-color: ##{@palette.neutral_1}'></div>
<div class='color neutral-0' style='background-color: ##{@palette.neutral_0}'></div>
</div></a>
<div class='select'><ul>" + options + '</ul></div>'
          end
        end
      else
#         template = field.template
#         field['template'] = nil
        concat render :partial => "#{field.template}", :locals => {:form => form, :field => field}
      end
      concat raw '</div>'
    end
  end
  
#   def parse_dynamic_string(str)
#     components = str.split('+')
#     components.each do |component|
# 
#     end
#   end

  def show_menus(menus)
    menus.each do |menu|
      show_menu(menu)
    end
  end

  def show_menu(menu)
    menu['attributes'] ||= {}
    menu['items'] ||= {}
    menu['template'] ||= nil
    menu['conditions'] ||= {}
    menu['header'] ||= nil
    if test_conditions(menu.conditions)
      attrStr = get_attribute_string(menu.attributes)
      concat raw '<div' + attrStr + '>'
      unless menu.header.nil?
        concat t(menu.header, :default => menu.header)
      end
      if menu.template.nil?
        concat raw '<ul>'
        menu.items.each do |item|
          show_menu_item(item)
        end
        concat raw '</ul>'
      else
        concat render :partial => "#{menu.template}", :locals => {:vars => menu}
      end
      concat raw '</div>'
    end
  end
    
  def show_menu_item(item)
    item['attributes'] ||= {}
    item['url_options'] ||= nil
    item['html_options'] ||= {}
    item['conditions'] ||= {}
    if test_conditions(item.conditions)
      attrStr = get_attribute_string(item.attributes)
      label = raw parse_dynamic_string(item.label)
      label = t(item.label, :default => item.label) if label == item.label
      url = parse_url_string(item.url, item.url_options)
      concat raw '<li' + attrStr + '>' + link_to(label, url, item.html_options) + '</li>'
    end
  end

  def get_attribute_string(attributes)
    string = ''
    attributes.each do |key, val|
      key = 'class' if key == 'cssClass'
      string << ' ' + key.to_s.tr('_', '-') + '="' + val.to_s + '"'
    end
    string
  end
  
  def test_conditions(conditions)
    proceed = true
    conditions.each do |test, value|
      proceed = test_condition(test, value)
      break unless proceed
    end
    proceed
  end

  def test_condition(test, value)
    proceed = false
    unless value.kind_of?(Array)
      values = [value]
    else
      values = value
    end
    trial = parse_dynamic_string(test)
    if trial == test
      proceed = values.include?(send(test + '?'))
    else
      proceed = values.include?(trial)
    end
    proceed
  end
    
  def parse_template_call(str)
    arg = nil
    if str.count('(') > 0
      str, match, arg = str.partition('(')
      arg = parse_dynamic_string(arg.chomp(')'))
    end
    call = 'show_' + str
    if arg
      send(call, arg)
    else
      send(call)
    end
  end

  def parse_concat_string(str)
    begin
      segments = str.split('+')
      if segments.count > 1
        value = ''
        segments.each do |seg|
          value += parse_dynamic_string(seg)
        end
      end
    rescue
      return
    end
    value
  end
 
  def parse_constant_string(str)
    begin
      segments = str.split('.')
      value = segments.shift.constantize
      segments.each do |prop|
        value = value.send(prop)
      end
    rescue
      return
    end
    value
  end

  def parse_variable_string(str)
    begin
      if str[0] == '@'
        segments = str.split('.')
        value = instance_variable_get(segments.shift)
        segments.each do |prop|
          value = value.send(prop)
        end
      end
#     rescue
#       return
    end
    value
  end
  
  def parse_url_string(str, options = nil)
    begin
      value = parse_dynamic_string(str)
      if value == str
        unless str[0] == '/' || str[0] == '#' || str[0..3] == 'http'
          # Create fully qualified URLs where possible
          value = ENV['APP_URL'] + send(str + '_path', options)
        else
          if str[0] == '/'
            # Create fully qualified URLs where possible
            value = ENV['APP_URL'] + value
          end
        end
      end
    rescue
      return
    end
    value
  end

  def parse_dynamic_string(str)
    begin
      unless value = parse_concat_string(str)
        case str[0]
          when '@'
            value = parse_variable_string(str)
          else
            unless value = parse_constant_string(str)
              value = str
            end
        end
      end
#     rescue
#       return
    end
    value
  end

  def escape_single_quotes(str)
    str.gsub(/\\|'/) { |c| "\\#{c}" }
  end

end
