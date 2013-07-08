module ApplicationHelper

  def support_email
    "support@terraling.com".html_safe
  end

  def link_to_google_web_font(font)
    "<link href='http://fonts.googleapis.com/css?family=#{u(font)}' rel='stylesheet' type='text/css'>".html_safe
  end

  def page_title
    ((content_for(:title) + " - " if content_for?(:title)).to_s + 'TerraLing').html_safe
  end

  def page_heading(text)
    content_tag(:h1, content_for(:title){ text })
  end

  def add_body_classes(*classes)
    @body_classes ||= []
    @body_classes += Array(classes).flatten
  end

  def body_classes(*additional_classes)
    classes = []
    classes << "current_user" if user_signed_in?
    classes << @body_classes if @body_classes
    classes << additional_classes
    classes.flatten.uniq.join(" - ")
  end
  
  def display_style_example(style_id)
    result = "<table class='show-table table table-bordered table-striped table-hover'>"
    case style_id
    when 0
      result += "<tr>
        <th>Ling</th>
        <th>Description</th>
        <th>Gloss</th>
        <th>Words</th>
        <th>Translation</th>
        <th class='small-comment'>Comment</th>
        </tr>
        <tr>
        <td>Afrikaans</td>
        <td>Test example of Afrikaans language</td>
        <td>Die studente lees</td>
        <td>the student.PL read </td>
        <td>The students are reading </td>
        <td class='small-comment'>This is the required order in main clauses, which are necessarily V2. It is also the order found in unmodified embedded clauses (i.e. dat die studente lees). Where modifiers are present, main and embedded clauses differ, though (Die studente lees gretig v</td>
        </tr>"
    when 1
      result += "<tr>
        <th>Ling</th>
        <th>Description</th>
        <th>Values</th>
        <th class='medium-comment'>Comment</th>
        </tr>
        <tr>
        <td>Afrikaans</td>
        <td>Test example of Afrikaans language</td>
        <td class='align-left'>
        Die studente lees
        <br />the student.PL read
        <br />The students are reading </td>
        <td class='medium-comment'>This is the required order in main clauses, which are necessarily V2. It is also the order found in unmodified embedded clauses (i.e. dat die studente lees). Where modifiers are present, main and embedded clauses differ, though (Die studente lees gretig v</td>
        </tr>"
    end
    return (result + "</table>").html_safe
  end

end
