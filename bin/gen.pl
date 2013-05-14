
# This chunk of stuff was generated by App::FatPacker. To find the original
# file's code, look for the end of this BEGIN block or the string 'FATPACK'
BEGIN {
my %fatpacked;

$fatpacked{"Text/Markdown.pm"} = <<'TEXT_MARKDOWN';
  package Text::Markdown;require 5.008_000;use strict;use warnings;use re 'eval';use Digest::MD5 qw(md5_hex);use Encode qw();use Carp qw(croak);use base 'Exporter';our$VERSION='1.000031';$VERSION=eval$VERSION;our@EXPORT_OK=qw(markdown);our ($g_nested_brackets,$g_nested_parens);$g_nested_brackets=qr{
      (?>                                 # Atomic matching
         [^\[\]]+                         # Anything other than brackets
       |
         \[
           (??{ $g_nested_brackets })     # Recursive set of nested brackets
         \]
      )*
  }x;$g_nested_parens=qr{
      (?>                                 # Atomic matching
         [^()\s]+                            # Anything other than parens or whitespace
       |
         \(
           (??{ $g_nested_parens })        # Recursive set of nested brackets
         \)
      )*
  }x;our%g_escape_table;for my$char (split //,'\\`*_{}[]()>#+-.!'){$g_escape_table{$char}=md5_hex($char)}sub new {my ($class,%p)=@_;$p{base_url}||='';$p{tab_width}=4 unless (defined$p{tab_width}and $p{tab_width}=~ m/^\d+$/);$p{empty_element_suffix}||=' />';$p{trust_list_start_value}=$p{trust_list_start_value}? 1 : 0;my$self={params=>\%p };bless$self,ref($class)|| $class;return$self}sub markdown {my ($self,$text,$options)=@_;unless (ref$self){if ($self ne __PACKAGE__){my$ob=__PACKAGE__->new();return$ob->markdown($self,$text)}else {croak('Calling ' .$self .'->markdown (as a class method) is not supported.')}}$options ||={};%$self=(%{$self->{params}},%$options,params=>$self->{params});$self->_CleanUpRunData($options);return$self->_Markdown($text)}sub _CleanUpRunData {my ($self,$options)=@_;$self->{_urls}=$options->{urls}? $options->{urls}: {};$self->{_titles}={};$self->{_html_blocks}={};$self->{_list_level}=0}sub _Markdown {my ($self,$text,$options)=@_;$text=$self->_CleanUpDoc($text);$text=$self->_HashHTMLBlocks($text,{interpret_markdown_on_attribute=>1});$text=$self->_StripLinkDefinitions($text);$text=$self->_RunBlockGamut($text,{wrap_in_p_tags=>1});$text=$self->_UnescapeSpecialChars($text);$text=$self->_ConvertCopyright($text);return$text ."\n"}sub urls {my ($self)=@_;return$self->{_urls}}sub _CleanUpDoc {my ($self,$text)=@_;$text =~ s{\r\n}{\n}g;$text =~ s{\r}{\n}g;$text .= "\n\n";$text=$self->_Detab($text);$text =~ s/^[ \t]+$//mg;return$text}sub _StripLinkDefinitions {my ($self,$text)=@_;my$less_than_tab=$self->{tab_width}- 1;while ($text =~ s{
              ^[ ]{0,$less_than_tab}\[(.+)\]: # id = \$1
                [ \t]*
                \n?               # maybe *one* newline
                [ \t]*
              <?(\S+?)>?          # url = \$2
                [ \t]*
                \n?               # maybe one newline
                [ \t]*
              (?:
                  (?<=\s)         # lookbehind for whitespace
                  ["(]
                  (.+?)           # title = \$3
                  [")]
                  [ \t]*
              )?  # title is optional
              (?:\n+|\Z)
          }{}omx){$self->{_urls}{lc $1}=$self->_EncodeAmpsAndAngles($2);if ($3){$self->{_titles}{lc $1}=$3;$self->{_titles}{lc $1}=~ s/"/&quot;/g}}return$text}sub _md5_utf8 {my$input=shift;return unless defined$input;if (Encode::is_utf8$input){return md5_hex(Encode::encode('utf8',$input))}else {return md5_hex($input)}}sub _HashHTMLBlocks {my ($self,$text,$options)=@_;my$less_than_tab=$self->{tab_width}- 1;my$block_tags=qr{
            (?:
              p         |  div     |  h[1-6]  |  blockquote  |  pre       |  table  |
              dl        |  ol      |  ul      |  script      |  noscript  |  form   |
              fieldset  |  iframe  |  math    |  ins         |  del
            )
          }x;my$tag_attrs=qr{
                          (?:                 # Match one attr name/value pair
                              \s+             # There needs to be at least some whitespace
                                              # before each attribute name.
                              [\w.:_-]+       # Attribute name
                              \s*=\s*
                              (?:
                                  ".+?"       # "Attribute value"
                               |
                                  '.+?'       # 'Attribute value'
                               |
                                  [^\s]+?      # AttributeValue (HTML5)
                              )
                          )*                  # Zero or more
                      }x;my$empty_tag=qr{< \w+ $tag_attrs \s* />}oxms;my$open_tag=qr{< $block_tags $tag_attrs \s* >}oxms;my$close_tag=undef;my$prefix_pattern=undef;my$markdown_attr=qr{ \s* markdown \s* = \s* (['"]) (.*?) \1 }xs;use Text::Balanced qw(gen_extract_tagged);my$extract_block=gen_extract_tagged($open_tag,$close_tag,$prefix_pattern,{ignore=>[$empty_tag]});my@chunks;while ($text =~ s{^(([ ]{0,$less_than_tab}<)?.*\n)}{}m){my$cur_line=$1;if (defined $2){my ($tag,$remainder,$prefix,$opening_tag,$text_in_tag,$closing_tag)=$extract_block->($cur_line .$text);if ($tag){if ($options->{interpret_markdown_on_attribute}and $opening_tag =~ s/$markdown_attr//i){my$markdown=$2;if ($markdown =~ /^(1|on|yes)$/){my$wrap_in_p_tags=$opening_tag =~ /^<(div|iframe)/;$tag=$prefix .$opening_tag ."\n" .$self->_RunBlockGamut($text_in_tag,{wrap_in_p_tags=>$wrap_in_p_tags})."\n" .$closing_tag }else {$tag=$prefix .$opening_tag .$text_in_tag .$closing_tag}}my$key=_md5_utf8($tag);$self->{_html_blocks}{$key}=$tag;push@chunks,"\n\n" .$key ."\n\n";$text=$remainder}else {push@chunks,$cur_line}}else {push@chunks,$cur_line}}push@chunks,$text;$text=join '',@chunks;return$text}sub _HashHR {my ($self,$text)=@_;my$less_than_tab=$self->{tab_width}- 1;$text =~ s{
                  (?:
                      (?<=\n\n)        # Starting after a blank line
                      |                # or
                      \A\n?            # the beginning of the doc
                  )
                  (                        # save in $1
                      [ ]{0,$less_than_tab}
                      <(hr)                # start tag = $2
                      \b                    # word break
                      ([^<>])*?            #
                      /?>                    # the matching end tag
                      [ \t]*
                      (?=\n{2,}|\Z)        # followed by a blank line or end of document
                  )
      }{
          my $key = _md5_utf8($1);
          $self->{_html_blocks}{$key} = $1;
          "\n\n" . $key . "\n\n";
      }egx;return$text}sub _HashHTMLComments {my ($self,$text)=@_;my$less_than_tab=$self->{tab_width}- 1;$text =~ s{
                  (?:
                      (?<=\n\n)        # Starting after a blank line
                      |                # or
                      \A\n?            # the beginning of the doc
                  )
                  (                        # save in $1
                      [ ]{0,$less_than_tab}
                      (?s:
                          <!
                          (--.*?--\s*)+
                          >
                      )
                      [ \t]*
                      (?=\n{2,}|\Z)        # followed by a blank line or end of document
                  )
      }{
          my $key = _md5_utf8($1);
          $self->{_html_blocks}{$key} = $1;
          "\n\n" . $key . "\n\n";
      }egx;return$text}sub _HashPHPASPBlocks {my ($self,$text)=@_;my$less_than_tab=$self->{tab_width}- 1;$text =~ s{
                  (?:
                      (?<=\n\n)        # Starting after a blank line
                      |                # or
                      \A\n?            # the beginning of the doc
                  )
                  (                        # save in $1
                      [ ]{0,$less_than_tab}
                      (?s:
                          <([?%])            # $2
                          .*?
                          \2>
                      )
                      [ \t]*
                      (?=\n{2,}|\Z)        # followed by a blank line or end of document
                  )
              }{
                  my $key = _md5_utf8($1);
                  $self->{_html_blocks}{$key} = $1;
                  "\n\n" . $key . "\n\n";
              }egx;return$text}sub _RunBlockGamut {my ($self,$text,$options)=@_;$text=$self->_DoHeaders($text);my$less_than_tab=$self->{tab_width}- 1;$text =~ s{^[ ]{0,$less_than_tab}(\*[ ]?){3,}[ \t]*$}{\n<hr$self->{empty_element_suffix}\n}gmx;$text =~ s{^[ ]{0,$less_than_tab}(-[ ]?){3,}[ \t]*$}{\n<hr$self->{empty_element_suffix}\n}gmx;$text =~ s{^[ ]{0,$less_than_tab}(_[ ]?){3,}[ \t]*$}{\n<hr$self->{empty_element_suffix}\n}gmx;$text=$self->_DoLists($text);$text=$self->_DoCodeBlocks($text);$text=$self->_DoBlockQuotes($text);$text=$self->_HashHTMLBlocks($text);$text=$self->_HashHR($text);$text=$self->_HashHTMLComments($text);$text=$self->_HashPHPASPBlocks($text);$text=$self->_FormParagraphs($text,{wrap_in_p_tags=>$options->{wrap_in_p_tags}});return$text}sub _RunSpanGamut {my ($self,$text)=@_;$text=$self->_DoCodeSpans($text);$text=$self->_EscapeSpecialCharsWithinTagAttributes($text);$text=$self->_EscapeSpecialChars($text);$text=$self->_DoImages($text);$text=$self->_DoAnchors($text);$text=$self->_DoAutoLinks($text);$text=$self->_EncodeAmpsAndAngles($text);$text=$self->_DoItalicsAndBold($text);$text =~ s/ {2,}\n/ <br$self->{empty_element_suffix}\n/g;return$text}sub _EscapeSpecialChars {my ($self,$text)=@_;my$tokens ||=$self->_TokenizeHTML($text);$text='';for my$cur_token (@$tokens){if ($cur_token->[0]eq "tag"){$cur_token->[1]=~ s! \* !$g_escape_table{'*'}!ogx;$cur_token->[1]=~ s! _  !$g_escape_table{'_'}!ogx;$text .= $cur_token->[1]}else {my$t=$cur_token->[1];$t=$self->_EncodeBackslashEscapes($t);$text .= $t}}return$text}sub _EscapeSpecialCharsWithinTagAttributes {my ($self,$text)=@_;my$tokens ||=$self->_TokenizeHTML($text);$text='';for my$cur_token (@$tokens){if ($cur_token->[0]eq "tag"){$cur_token->[1]=~ s! \\ !$g_escape_table{'\\'}!gox;$cur_token->[1]=~ s{ (?<=.)</?code>(?=.)  }{$g_escape_table{'`'}}gox;$cur_token->[1]=~ s! \* !$g_escape_table{'*'}!gox;$cur_token->[1]=~ s! _  !$g_escape_table{'_'}!gox}$text .= $cur_token->[1]}return$text}sub _DoAnchors {my ($self,$text)=@_;$text =~ s{
          (                   # wrap whole match in $1
            \[
              ($g_nested_brackets)    # link text = $2
            \]
  
            [ ]?              # one optional space
            (?:\n[ ]*)?       # one optional newline followed by spaces
  
            \[
              (.*?)       # id = $3
            \]
          )
      }{
          my $whole_match = $1;
          my $link_text   = $2;
          my $link_id     = lc $3;
  
          if ($link_id eq "") {
              $link_id = lc $link_text;   # for shortcut links like [this][].
          }
  
          $link_id =~ s{[ ]*\n}{ }g; # turn embedded newlines into spaces
  
          $self->_GenerateAnchor($whole_match, $link_text, $link_id);
      }xsge;$text =~ s{
          (               # wrap whole match in $1
            \[
              ($g_nested_brackets)    # link text = $2
            \]
            \(            # literal paren
              [ \t]*
              ($g_nested_parens)   # href = $3
              [ \t]*
              (           # $4
                (['"])    # quote char = $5
                (.*?)     # Title = $6
                \5        # matching quote
                [ \t]*    # ignore any spaces/tabs between closing quote and )
              )?          # title is optional
            \)
          )
      }{
          my $result;
          my $whole_match = $1;
          my $link_text   = $2;
          my $url         = $3;
          my $title       = $6;
  
          $self->_GenerateAnchor($whole_match, $link_text, undef, $url, $title);
      }xsge;$text =~ s{
          (                    # wrap whole match in $1
            \[
              ([^\[\]]+)        # link text = $2; can't contain '[' or ']'
            \]
          )
      }{
          my $result;
          my $whole_match = $1;
          my $link_text   = $2;
          (my $link_id = lc $2) =~ s{[ ]*\n}{ }g; # lower-case and turn embedded newlines into spaces
  
          $self->_GenerateAnchor($whole_match, $link_text, $link_id);
      }xsge;return$text}sub _GenerateAnchor {my ($self,$whole_match,$link_text,$link_id,$url,$title,$attributes)=@_;my$result;$attributes='' unless defined$attributes;if (!defined$url && defined$self->{_urls}{$link_id}){$url=$self->{_urls}{$link_id}}if (!defined$url){return$whole_match}$url =~ s! \* !$g_escape_table{'*'}!gox;$url =~ s!  _ !$g_escape_table{'_'}!gox;$url =~ s{^<(.*)>$}{$1};$result=qq{<a href="$url"};if (!defined$title && defined$link_id && defined$self->{_titles}{$link_id}){$title=$self->{_titles}{$link_id}}if (defined$title){$title =~ s/"/&quot;/g;$title =~ s! \* !$g_escape_table{'*'}!gox;$title =~ s!  _ !$g_escape_table{'_'}!gox;$result .= qq{ title="$title"}}$result .= "$attributes>$link_text</a>";return$result}sub _DoImages {my ($self,$text)=@_;$text =~ s{
          (               # wrap whole match in $1
            !\[
              (.*?)       # alt text = $2
            \]
  
            [ ]?              # one optional space
            (?:\n[ ]*)?       # one optional newline followed by spaces
  
            \[
              (.*?)       # id = $3
            \]
  
          )
      }{
          my $result;
          my $whole_match = $1;
          my $alt_text    = $2;
          my $link_id     = lc $3;
  
          if ($link_id eq '') {
              $link_id = lc $alt_text;     # for shortcut links like ![this][].
          }
  
          $self->_GenerateImage($whole_match, $alt_text, $link_id);
      }xsge;$text =~ s{
          (               # wrap whole match in $1
            !\[
              (.*?)       # alt text = $2
            \]
            \(            # literal paren
              [ \t]*
              ($g_nested_parens)  # src url - href = $3
              [ \t]*
              (           # $4
                (['"])    # quote char = $5
                (.*?)     # title = $6
                \5        # matching quote
                [ \t]*
              )?          # title is optional
            \)
          )
      }{
          my $result;
          my $whole_match = $1;
          my $alt_text    = $2;
          my $url         = $3;
          my $title       = '';
          if (defined($6)) {
              $title      = $6;
          }
  
          $self->_GenerateImage($whole_match, $alt_text, undef, $url, $title);
      }xsge;return$text}sub _GenerateImage {my ($self,$whole_match,$alt_text,$link_id,$url,$title,$attributes)=@_;my$result;$attributes='' unless defined$attributes;$alt_text ||='';$alt_text =~ s/"/&quot;/g;if (!defined$url && defined$self->{_urls}{$link_id}){$url=$self->{_urls}{$link_id}}return$whole_match unless defined$url;$url =~ s! \* !$g_escape_table{'*'}!ogx;$url =~ s!  _ !$g_escape_table{'_'}!ogx;$url =~ s{^<(.*)>$}{$1};if (!defined$title && length$link_id && defined$self->{_titles}{$link_id}&& length$self->{_titles}{$link_id}){$title=$self->{_titles}{$link_id}}$result=qq{<img src="$url" alt="$alt_text"};if (defined$title && length$title){$title =~ s! \* !$g_escape_table{'*'}!ogx;$title =~ s!  _ !$g_escape_table{'_'}!ogx;$title =~ s/"/&quot;/g;$result .= qq{ title="$title"}}$result .= $attributes .$self->{empty_element_suffix};return$result}sub _DoHeaders {my ($self,$text)=@_;$text =~ s{ ^(.+)[ \t]*\n=+[ \t]*\n+ }{
          $self->_GenerateHeader('1', $1);
      }egmx;$text =~ s{ ^(.+)[ \t]*\n-+[ \t]*\n+ }{
          $self->_GenerateHeader('2', $1);
      }egmx;my$l;$text =~ s{
              ^(\#{1,6})  # $1 = string of #'s
              [ \t]*
              (.+?)       # $2 = Header text
              [ \t]*
              \#*         # optional closing #'s (not counted)
              \n+
          }{
              my $h_level = length($1);
              $self->_GenerateHeader($h_level, $2);
          }egmx;return$text}sub _GenerateHeader {my ($self,$level,$id)=@_;return "<h$level>" .$self->_RunSpanGamut($id)."</h$level>\n\n"}sub _DoLists {my ($self,$text)=@_;my$less_than_tab=$self->{tab_width}- 1;my$marker_ul=qr/[*+-]/;my$marker_ol=qr/\d+[.]/;my$marker_any=qr/(?:$marker_ul|$marker_ol)/;my$whole_list=qr{
          (                               # $1 = whole list
            (                             # $2
              [ ]{0,$less_than_tab}
              (${marker_any})             # $3 = first list item marker
              [ \t]+
            )
            (?s:.+?)
            (                             # $4
                \z
              |
                \n{2,}
                (?=\S)
                (?!                       # Negative lookahead for another list item marker
                  [ \t]*
                  ${marker_any}[ \t]+
                )
            )
          )
      }mx;if ($self->{_list_level}){$text =~ s{
                  ^
                  $whole_list
              }{
                  my $list = $1;
                  my $marker = $3;
                  my $list_type = ($marker =~ m/$marker_ul/) ? "ul" : "ol";
                  # Turn double returns into triple returns, so that we can make a
                  # paragraph for the last item in a list, if necessary:
                  $list =~ s/\n{2,}/\n\n\n/g;
                  my $result = ( $list_type eq 'ul' ) ?
                      $self->_ProcessListItemsUL($list, $marker_ul)
                    : $self->_ProcessListItemsOL($list, $marker_ol);
  
                  $result = $self->_MakeList($list_type, $result, $marker);
                  $result;
              }egmx}else {$text =~ s{
                  (?:(?<=\n\n)|\A\n?)
                  $whole_list
              }{
                  my $list = $1;
                  my $marker = $3;
                  my $list_type = ($marker =~ m/$marker_ul/) ? "ul" : "ol";
                  # Turn double returns into triple returns, so that we can make a
                  # paragraph for the last item in a list, if necessary:
                  $list =~ s/\n{2,}/\n\n\n/g;
                  my $result = ( $list_type eq 'ul' ) ?
                      $self->_ProcessListItemsUL($list, $marker_ul)
                    : $self->_ProcessListItemsOL($list, $marker_ol);
                  $result = $self->_MakeList($list_type, $result, $marker);
                  $result;
              }egmx}return$text}sub _MakeList {my ($self,$list_type,$content,$marker)=@_;if ($list_type eq 'ol' and $self->{trust_list_start_value}){my ($num)=$marker =~ /^(\d+)[.]/;return "<ol start='$num'>\n" .$content ."</ol>\n"}return "<$list_type>\n" .$content ."</$list_type>\n"}sub _ProcessListItemsOL {my ($self,$list_str,$marker_any)=@_;$self->{_list_level}++;$list_str =~ s/\n{2,}\z/\n/;$list_str =~ s{
          (\n)?                           # leading line = $1
          (^[ \t]*)                       # leading whitespace = $2
          ($marker_any) [ \t]+            # list marker = $3
          ((?s:.+?)                       # list item text   = $4
          (\n{1,2}))
          (?= \n* (\z | \2 ($marker_any) [ \t]+))
      }{
          my $item = $4;
          my $leading_line = $1;
          my $leading_space = $2;
  
          if ($leading_line or ($item =~ m/\n{2,}/)) {
              $item = $self->_RunBlockGamut($self->_Outdent($item), {wrap_in_p_tags => 1});
          }
          else {
              # Recursion for sub-lists:
              $item = $self->_DoLists($self->_Outdent($item));
              chomp $item;
              $item = $self->_RunSpanGamut($item);
          }
  
          "<li>" . $item . "</li>\n";
      }egmxo;$self->{_list_level}--;return$list_str}sub _ProcessListItemsUL {my ($self,$list_str,$marker_any)=@_;$self->{_list_level}++;$list_str =~ s/\n{2,}\z/\n/;$list_str =~ s{
          (\n)?                           # leading line = $1
          (^[ \t]*)                       # leading whitespace = $2
          ($marker_any) [ \t]+            # list marker = $3
          ((?s:.+?)                       # list item text   = $4
          (\n{1,2}))
          (?= \n* (\z | \2 ($marker_any) [ \t]+))
      }{
          my $item = $4;
          my $leading_line = $1;
          my $leading_space = $2;
  
          if ($leading_line or ($item =~ m/\n{2,}/)) {
              $item = $self->_RunBlockGamut($self->_Outdent($item), {wrap_in_p_tags => 1});
          }
          else {
              # Recursion for sub-lists:
              $item = $self->_DoLists($self->_Outdent($item));
              chomp $item;
              $item = $self->_RunSpanGamut($item);
          }
  
          "<li>" . $item . "</li>\n";
      }egmxo;$self->{_list_level}--;return$list_str}sub _DoCodeBlocks {my ($self,$text)=@_;$text =~ s{
          (?:\n\n|\A)
          (                # $1 = the code block -- one or more lines, starting with a space/tab
            (?:
              (?:[ ]{$self->{tab_width}} | \t)   # Lines must start with a tab or a tab-width of spaces
              .*\n+
            )+
          )
          ((?=^[ ]{0,$self->{tab_width}}\S)|\Z)    # Lookahead for non-space at line-start, or end of doc
      }{
          my $codeblock = $1;
          my $result;  # return value
  
          $codeblock = $self->_EncodeCode($self->_Outdent($codeblock));
          $codeblock = $self->_Detab($codeblock);
          $codeblock =~ s/\A\n+//;  # trim leading newlines
          $codeblock =~ s/\n+\z//;  # trim trailing newlines
  
          $result = "\n\n<pre><code>" . $codeblock . "\n</code></pre>\n\n";
  
          $result;
      }egmx;return$text}sub _DoCodeSpans {my ($self,$text)=@_;$text =~ s@
              (?<!\\)        # Character before opening ` can't be a backslash
              (`+)        # $1 = Opening run of `
              (.+?)        # $2 = The code block
              (?<!`)
              \1            # Matching closer
              (?!`)
          @
               my $c = "$2";
               $c =~ s/^[ \t]*//g; # leading whitespace
               $c =~ s/[ \t]*$//g; # trailing whitespace
               $c = $self->_EncodeCode($c);
              "<code>$c</code>";
          @egsx;return$text}sub _EncodeCode {my$self=shift;local $_=shift;s/&/&amp;/g;{no warnings 'once';if (defined($blosxom::version)){s/\$/&#036;/g}}s! <  !&lt;!gx;s! >  !&gt;!gx;s! \* !$g_escape_table{'*'}!ogx;s! _  !$g_escape_table{'_'}!ogx;s! {  !$g_escape_table{'{'}!ogx;s! }  !$g_escape_table{'}'}!ogx;s! \[ !$g_escape_table{'['}!ogx;s! \] !$g_escape_table{']'}!ogx;s! \\ !$g_escape_table{'\\'}!ogx;return $_}sub _DoItalicsAndBold {my ($self,$text)=@_;$text =~ s{ ^(\*\*|__) (?=\S) (.+?[*_]*) (?<=\S) \1 }
          {<strong>$2</strong>}gsx;$text =~ s{ ^(\*|_) (?=\S) (.+?) (?<=\S) \1 }
          {<em>$2</em>}gsx;$text =~ s{ (?<=\W) (\*\*|__) (?=\S) (.+?[*_]*) (?<=\S) \1 }
          {<strong>$2</strong>}gsx;$text =~ s{ (?<=\W) (\*|_) (?=\S) (.+?) (?<=\S) \1 }
          {<em>$2</em>}gsx;$text =~ s{ (?<=\W) (\*\*|__) (?=\S) (.+?[*_]*) (?<=\S) \1 }
          {<strong>$2</strong>}gsx;$text =~ s{ (?<=\W) (\*|_) (?=\S) (.+?) (?<=\S) \1 }
          {<em>$2</em>}gsx;return$text}sub _DoBlockQuotes {my ($self,$text)=@_;$text =~ s{
            (                             # Wrap whole match in $1
              (
                ^[ \t]*>[ \t]?            # '>' at the start of a line
                  .+\n                    # rest of the first line
                (.+\n)*                   # subsequent consecutive lines
                \n*                       # blanks
              )+
            )
          }{
              my $bq = $1;
              $bq =~ s/^[ \t]*>[ \t]?//gm;    # trim one level of quoting
              $bq =~ s/^[ \t]+$//mg;          # trim whitespace-only lines
              $bq = $self->_RunBlockGamut($bq, {wrap_in_p_tags => 1});      # recurse
  
              $bq =~ s/^/  /mg;
              # These leading spaces screw with <pre> content, so we need to fix that:
              $bq =~ s{
                      (\s*<pre>.+?</pre>)
                  }{
                      my $pre = $1;
                      $pre =~ s/^  //mg;
                      $pre;
                  }egsx;
  
              "<blockquote>\n$bq\n</blockquote>\n\n";
          }egmx;return$text}sub _FormParagraphs {my ($self,$text,$options)=@_;$text =~ s/\A\n+//;$text =~ s/\n+\z//;my@grafs=split(/\n{2,}/,$text);for (@grafs){unless (defined($self->{_html_blocks}{$_})){$_=$self->_RunSpanGamut($_);if ($options->{wrap_in_p_tags}){s/^([ \t]*)/<p>/;$_ .= "</p>"}}}for (@grafs){if (defined($self->{_html_blocks}{$_})){$_=$self->{_html_blocks}{$_}}}return join "\n\n",@grafs}sub _EncodeAmpsAndAngles {my ($self,$text)=@_;return '' if (!defined$text or!length$text);$text =~ s/&(?!#?[xX]?(?:[0-9a-fA-F]+|\w+);)/&amp;/g;$text =~ s{<(?![a-z/?\$!])}{&lt;}gi;$text =~ s{
          (?<=<!--) # Begin comment
          (.*?)     # Anything inside
          (?=-->)   # End comments
      }{
          my $t = $1;
          $t =~ s/&amp;/&/g;
          $t =~ s/&lt;/</g;
          $t;
      }egsx;return$text}sub _EncodeBackslashEscapes {my$self=shift;local $_=shift;s! \\\\  !$g_escape_table{'\\'}!ogx;s! \\`   !$g_escape_table{'`'}!ogx;s! \\\*  !$g_escape_table{'*'}!ogx;s! \\_   !$g_escape_table{'_'}!ogx;s! \\\{  !$g_escape_table{'{'}!ogx;s! \\\}  !$g_escape_table{'}'}!ogx;s! \\\[  !$g_escape_table{'['}!ogx;s! \\\]  !$g_escape_table{']'}!ogx;s! \\\(  !$g_escape_table{'('}!ogx;s! \\\)  !$g_escape_table{')'}!ogx;s! \\>   !$g_escape_table{'>'}!ogx;s! \\\#  !$g_escape_table{'#'}!ogx;s! \\\+  !$g_escape_table{'+'}!ogx;s! \\\-  !$g_escape_table{'-'}!ogx;s! \\\.  !$g_escape_table{'.'}!ogx;s{ \\!  }{$g_escape_table{'!'}}ogx;return $_}sub _DoAutoLinks {my ($self,$text)=@_;$text =~ s{<((https?|ftp):[^'">\s]+)>}{<a href="$1">$1</a>}gi;$text =~ s{
          <
          (?:mailto:)?
          (
              [-.\w\+]+
              \@
              [-a-z0-9]+(\.[-a-z0-9]+)*\.[a-z]+
          )
          >
      }{
          $self->_EncodeEmailAddress( $self->_UnescapeSpecialChars($1) );
      }egix;return$text}sub _EncodeEmailAddress {my ($self,$addr)=@_;my@encode=(sub {'&#' .ord(shift).';'},sub {'&#x' .sprintf("%X",ord(shift)).';'},sub {shift},);$addr="mailto:" .$addr;$addr =~ s{(.)}{
          my $char = $1;
          if ( $char eq '@' ) {
              # this *must* be encoded. I insist.
              $char = $encode[int rand 1]->($char);
          }
          elsif ( $char ne ':' ) {
              # leave ':' alone (to spot mailto: later)
              my $r = rand;
              # roughly 10% raw, 45% hex, 45% dec
              $char = (
                  $r > .9   ?  $encode[2]->($char)  :
                  $r < .45  ?  $encode[1]->($char)  :
                               $encode[0]->($char)
              );
          }
          $char;
      }gex;$addr=qq{<a href="$addr">$addr</a>};$addr =~ s{">.+?:}{">};return$addr}sub _UnescapeSpecialChars {my ($self,$text)=@_;while(my($char,$hash)=each(%g_escape_table)){$text =~ s/$hash/$char/g}return$text}sub _TokenizeHTML {my ($self,$str)=@_;my$pos=0;my$len=length$str;my@tokens;my$depth=6;my$nested_tags=join('|',('(?:<[a-z/!$](?:[^<>]')x $depth).(')*>)' x $depth);my$match=qr/(?s: <! ( -- .*? -- \s* )+ > ) |  # comment
                     (?s: <\? .*? \?> ) |              # processing instruction
                     $nested_tags/iox;while ($str =~ m/($match)/og){my$whole_tag=$1;my$sec_start=pos$str;my$tag_start=$sec_start - length$whole_tag;if ($pos < $tag_start){push@tokens,['text',substr($str,$pos,$tag_start - $pos)]}push@tokens,['tag',$whole_tag];$pos=pos$str}push@tokens,['text',substr($str,$pos,$len - $pos)]if$pos < $len;\@tokens}sub _Outdent {my ($self,$text)=@_;$text =~ s/^(\t|[ ]{1,$self->{tab_width}})//gm;return$text}sub _Detab {my ($self,$text)=@_;do {}while ($text =~ s{^(.*?)\t}{$1.(' ' x ($self->{tab_width} - length($1) % $self->{tab_width}))}mge);return$text}sub _ConvertCopyright {my ($self,$text)=@_;$text =~ s/&copy;/&#xA9;/gi;return$text}1;
TEXT_MARKDOWN

$fatpacked{"Text/MicroTemplate.pm"} = <<'TEXT_MICROTEMPLATE';
  package Text::MicroTemplate;require Exporter;use strict;use warnings;use constant DEBUG=>$ENV{MICRO_TEMPLATE_DEBUG}|| 0;use 5.00800;use Carp 'croak';use Scalar::Util;our$VERSION='0.19';our@ISA=qw(Exporter);our@EXPORT_OK=qw(encoded_string build_mt render_mt);our%EXPORT_TAGS=(all=>[@EXPORT_OK ],);our$_mt_setter='';sub new {my$class=shift;my$self=bless {code=>undef,comment_mark=>'#',expression_mark=>'=',line_start=>'?',template=>undef,tree=>[],tag_start=>'<?',tag_end=>'?>',escape_func=>\&_inline_escape_html,package_name=>undef,@_==1 ? ref($_[0])? %{$_[0]}: (template=>$_[0]): @_,},$class;if (defined$self->{template}){$self->parse($self->{template})}unless (defined$self->{package_name}){$self->{package_name}='main';my$i=0;while (my$c=caller(++$i)){if ($c !~ /^Text::MicroTemplate\b/){$self->{package_name}=$c;last}}}$self}sub escape_func {my$self=shift;if (@_){$self->{escape_func}=shift}$self->{escape_func}}sub package_name {my$self=shift;if (@_){$self->{package_name}=shift}$self->{package_name}}sub template {shift->{template}}sub code {my$self=shift;unless (defined$self->{code}){$self->_build()}$self->{code}}sub _build {my$self=shift;my$escape_func=$self->{escape_func}|| '';my$embed_escape_func=ref($escape_func)eq 'CODE' ? $escape_func : sub{$escape_func ."(@_)"};my@lines;my$last_was_code;my$last_text;for my$line (@{$self->{tree}}){push@lines,'';for (my$j=0;$j < @{$line};$j += 2){my$type=$line->[$j];my$value=$line->[$j + 1];if ($type ne 'text' && defined$last_text){$lines[$j==0 && @lines >= 2 ? -2 : -1 ].= "\$_MT .=\"$last_text\";";undef$last_text}my$newline=chomp$value;if ($last_was_code && $type ne 'code'){$lines[-1].= ';';undef$last_was_code}if ($type eq 'text'){$value=quotemeta($value);$value .= '\n' if$newline;$last_text=defined$last_text ? "$last_text$value" : $value}if ($type eq 'code'){$lines[-1].= $value;$last_was_code=1}if ($type eq 'expr'){my$escaped=$embed_escape_func->('$_MT_T');$lines[-1].= "\$_MT_T = $value;\$_MT .= ref \$_MT_T eq 'Text::MicroTemplate::EncodedString' ? \$\$_MT_T : $escaped; \$_MT_T = '';"}}}if ($last_was_code){$lines[-1].= "\n;"}if (defined$last_text){$lines[-1].= "\$_MT .=\"$last_text\";"}$lines[0]=q/sub { my $_MT = ''; local $/ .$self->{package_name}.q/::_MTREF = \$_MT; my $_MT_T = '';/ .(@lines ? $lines[0]: '');$lines[-1].= q/return $_MT; }/;$self->{code}=join "\n",@lines;return$self}sub parse {my ($self,$tmpl)=@_;$self->{template}=$tmpl;delete$self->{tree};delete$self->{code};my$line_start=quotemeta$self->{line_start};my$tag_start=quotemeta$self->{tag_start};my$tag_end=quotemeta$self->{tag_end};my$cmnt_mark=quotemeta$self->{comment_mark};my$expr_mark=quotemeta$self->{expression_mark};my$state='text';my$multiline_expression=0;my@lines=split /(\n)/,$tmpl;while (@lines){my$line=shift@lines;my$newline=undef;if (@lines){shift@lines;$newline=1}if ($line =~ /^$line_start\s+(.*)$/){push @{$self->{tree}},['code',$1];$multiline_expression=0;next}if ($line =~ /^$line_start$expr_mark\s+(.+)$/){push @{$self->{tree}},['expr',$1,$newline ? ('text',"\n"): (),];$multiline_expression=0;next}if ($line =~ /^$line_start$cmnt_mark\s+$/){push @{$self->{tree}},[];$multiline_expression=0;next}if ($line =~ /(\\+)$/){my$length=length $1;if ($length==1){$line =~ s/\\$//}if ($length >= 2){$line =~ s/\\\\$/\\/;$line .= "\n"}}else {$line .= "\n" if$newline}my@token;for my$token (split /
              (
                  $tag_start$expr_mark     # Expression
              |
                  $tag_start$cmnt_mark     # Comment
              |
                  $tag_start               # Code
              |
                  $tag_end                 # End
              )
          /x,$line){next if$token eq '';if ($token =~ /^$tag_end$/){$state='text';$multiline_expression=0}elsif ($token =~ /^$tag_start$/){$state='code'}elsif ($token =~ /^$tag_start$cmnt_mark$/){$state='cmnt'}elsif ($token =~ /^$tag_start$expr_mark$/){$state='expr'}else {next if$state eq 'cmnt';$state='code' if$multiline_expression;$multiline_expression=1 if$state eq 'expr';push@token,$state,$token}}push @{$self->{tree}},\@token}return$self}sub _context {my ($self,$text,$line)=@_;my@lines=split /\n/,$text;join '',map {0 < $_ && $_ <= @lines ? sprintf("%4d: %s\n",$_,$lines[$_ - 1]): ''}($line - 2).. ($line + 2)}sub _error {my ($self,$error,$line_offset,$from)=@_;if ($error =~ /^(.*)\s+at\s+\(eval\s+\d+\)\s+line\s+(\d+)/){my$reason=$1;my$line=$2 - $line_offset;my$delim='-' x 76;my$report="$reason at line $line in template passed from $from.\n";my$template=$self->_context($self->{template},$line);$report .= "$delim\n$template$delim\n";if (DEBUG){my$code=$self->_context($self->code,$line);$report .= "$code$delim\n";$report .= $error}return$report}return "Template error: $error"}sub encoded_string {Text::MicroTemplate::EncodedString->new($_[0])}sub _inline_escape_html{my($variable)=@_;my$source=qq{
          do{
              $variable =~ s/([&><"'])/\$Text::MicroTemplate::_escape_table{\$1}/ge;
              $variable;
          }
      };$source =~ s/\n//g;return$source}our%_escape_table=('&'=>'&amp;','>'=>'&gt;','<'=>'&lt;',q{"}=>'&quot;',q{'}=>'&#39;');sub escape_html {my$str=shift;return '' unless defined$str;return$str->as_string if ref$str eq 'Text::MicroTemplate::EncodedString';$str =~ s/([&><"'])/$_escape_table{$1}/ge;return$str}sub build_mt {my$mt=Text::MicroTemplate->new(@_);$mt->build()}sub build {my$_mt=shift;Scalar::Util::weaken($_mt)if$_mt_setter;my$_code=$_mt->code;my$_from=sub {my$i=0;while (my@c=caller(++$i)){return "$c[1] at line $c[2]" if$c[0]ne __PACKAGE__}''}->();my$expr=<< "...";if(DEBUG >= 2){DEBUG >= 3 ? die$expr : warn$expr}my$die_msg;{local $@;if (my$_builder=eval($expr)){return$_builder}$die_msg=$_mt->_error($@,4,$_from)}die$die_msg}sub render_mt {my$builder=build_mt(shift);$builder->(@_)}sub filter {my ($self,$callback)=@_;my$mtref=do {no strict 'refs';${"$self->{package_name}::_MTREF"}};my$before=$$mtref;$$mtref='';return sub {my$inner_func=shift;$inner_func->(@_);local $_=$$mtref;my$retval=$callback->($$mtref);no warnings 'uninitialized';if (($retval =~ /^\d+$/ and $_ ne $$mtref)or (defined$retval and!$retval)){$$mtref=$before .$_}else {$$mtref=$before .$retval}}}package Text::MicroTemplate::EncodedString;use strict;use warnings;use overload q{""}=>sub {shift->as_string},fallback=>1;sub new {my ($klass,$str)=@_;bless \$str,$klass}sub as_string {my$self=shift;$$self}1;
  package $_mt->{package_name};
  sub {
      ${_mt_setter}local \$SIG{__WARN__} = sub { print STDERR \$_mt->_error(shift, 4, \$_from) };
      Text::MicroTemplate::encoded_string((
          $_code
      )->(\@_));
  }
  ...
TEXT_MICROTEMPLATE

$fatpacked{"Text/MicroTemplate/EncodedString.pm"} = <<'TEXT_MICROTEMPLATE_ENCODEDSTRING';
  use Text::MicroTemplate;1;
TEXT_MICROTEMPLATE_ENCODEDSTRING

$fatpacked{"Text/MicroTemplate/File.pm"} = <<'TEXT_MICROTEMPLATE_FILE';
  package Text::MicroTemplate::File;use strict;use warnings;use File::Spec;use Text::MicroTemplate;use Carp qw(croak);our@ISA=qw(Text::MicroTemplate);sub new {my$klass=shift;my$self=$klass->SUPER::new(@_);$self->{include_path}||=['.' ];unless (defined$self->{open_layer}){$self->{open_layer}=':utf8'}unless (ref$self->{include_path}){$self->{include_path}=[$self->{include_path}]}$self->{use_cache}||=0;$self->{cache}={};$self}sub include_path {my$self=shift;croak "This is readonly accessor" if @_;$self->{include_path}}sub open_layer {my$self=shift;$self->{open_layer}=$_[0]if @_;$self->{open_layer}}sub use_cache {my$self=shift;$self->{use_cache}=$_[0]if @_;$self->{use_cache}}sub build_file {my ($self,$file)=@_;if ($self->{use_cache}==2){if (my$e=$self->{cache}->{$file}){return$e->[1]}}my ($filepath,@st);if (File::Spec->file_name_is_absolute($file)){$filepath=$file;@st=stat$filepath}else {for my$path (@{$self->{include_path}}){$filepath=$path .'/' .$file;@st=stat$filepath and last}}croak "could not find template file: $file (include_path: @{$self->{include_path}})" unless@st;if (my$e=$self->{cache}->{$file}){return$e->[1]if$st[9]==$e->[0]}open my$fh,"<$self->{open_layer}",$filepath or croak "failed to open:$filepath:$!";my$src=do {local $/;<$fh>};close$fh;$self->parse($src);local$Text::MicroTemplate::_mt_setter='my $_mt = shift;';my$f=$self->build();$self->{cache}->{$file}=[$st[9],$f,]if$self->{use_cache};return$f}sub render_file {my$self=shift;my$file=shift;$self->build_file($file)->($self,@_)}sub wrapper_file {my$self=shift;my$file=shift;my@args=@_;my$mtref=do {no strict 'refs';${"$self->{package_name}::_MTREF"}};my$before=$$mtref;$$mtref='';return sub {my$inner_func=shift;$inner_func->(@_);$$mtref=$before .$self->render_file($file,Text::MicroTemplate::encoded_string($$mtref),@args)->as_string}}1;
TEXT_MICROTEMPLATE_FILE

s/^  //mg for values %fatpacked;

unshift @INC, sub {
  if (my $fat = $fatpacked{$_[1]}) {
    if ($] < 5.008) {
      return sub {
        return 0 unless length $fat;
        $fat =~ s/^([^\n]*\n?)//;
        $_ = $1;
        return 1;
      };
    }
    open my $fh, '<', \$fat
      or die "FatPacker error loading $_[1] (could be a perl installation issue?)";
    return $fh;
  }
  return
};

} # END OF FATPACK CODE

use strict;
use warnings;
use utf8;
use Encode;
use File::Basename;
use File::Spec;
use Getopt::Long;
use Pod::Usage;
use Text::Markdown qw/markdown/;
use Text::MicroTemplate qw/render_mt/;

my $template_file = File::Spec->catfile(dirname(__FILE__), '..', 'docs', 'template', 'template.mt');
GetOptions(
    'template=s' => \$template_file,
    'output'     => \my $output,
    'reload'     => \my $reload,
    'h|help'     => \my $help,
) or pod2usage(2);
pod2usage(1) if $help;

my $filename = shift or pod2usage("Missing filename");
my $src = do {
    open my $fh, '<', $filename or die $!;
    local $/; <$fh>;
};
my @sections = map { decode_utf8(markdown($_)) } split /^----$/m, $src;
my ($title) = $sections[0] =~ m!<h\d\s*[\w="]*>(.*?)</h\d>!;

my $template = do {
    open my $fh, '<:encoding(utf-8)', $template_file or die $!;
    local $/; <$fh>;
};
my $html = render_mt($template, $title, \@sections);

if ($output) {
    (my $output_file = $filename) =~ s/\..+$//;
    open my $fh, '>:encoding(utf-8)', "$output_file.html" or die $!;
    print {$fh} $html;
} else {
    print encode_utf8($html);
}
if ($reload) {
    system q{osascript -e 'tell application "Google Chrome" to reload active tab of window 1'};
}

__END__

=head1 NAME

gen.pl - Slide generator written in Markdown

=head1 SYNOPSIS

  % gen.pl filename > slide.html

      --template  (default: docs/template/template.mt)
      --output
      --reload    Reload with Google Chrome (only OS X ;)

      --help      Show this help

=head1 TIPS

  % cpanm App::pfswatch
  % pfswatch docs --pipe -e 'xargs -I{} perl bin/gen.pl {} --output --reload' -q

=cut