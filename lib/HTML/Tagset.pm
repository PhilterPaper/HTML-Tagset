package HTML::Tagset;

use strict;

=head1 NAME

HTML::Tagset - data tables useful in parsing HTML

=head1 VERSION

Version 3.20

=cut

use vars qw( $VERSION );

our $VERSION = '3.20'; # VERSION

=head1 SYNOPSIS

  use HTML::Tagset;
  # Then use any of the items in the HTML::Tagset package
  #  as need arises

=head1 DESCRIPTION

This module contains several data tables useful in various kinds of
HTML parsing operations.

Note that all tag names used are lowercase.

In the following documentation, a "hashset" is a hash being used as a
set -- the hash conveys that its keys are there, and the actual values
associated with the keys are not significant.  (But what values are
there, are always true.)

=cut

use vars qw(
  $VERSION
  %emptyElement %optionalEndTag %linkElements %boolean_attr
  %isHeadElement %isBodyElement %isPhraseMarkup
  %isBlockElement %elementAttributes
  %is_Possible_Strict_P_Content
  %isHeadOrBodyElement
  %isList %isTableElement %isFormElement
  %isKnown %canTighten
  @p_closure_barriers
  %isCDATA_Parent
);

# list dependencies:
#   %emptyElement (none)
#   %optionalEndTag (none)
#   %linkElements (none)
#   %booleanAttr (none)
#   %isHeadOrBodyElement (none)
#   %isBlockElement (none)
#   %isPhraseMarkup (none)
#   %isFormElement (none)
#   %is_Possible_Strict_P_Content ( %isPhraseMarkup, %isFormElement )
#   %isHeadElement ( %isHeadOrBodyElement )
#   %isList (none)
#   %isTableElement (none)
#   %isBodyElement ( %isFormElement, %isBlockElement, %isPhraseMarkup,
#                    %isTableElement, %isHeadOrBodyElement )
#   %isKnown ( %isHeadElement, %isBodyElement )
#   %canTighten ( %isKnown )
#   @p_closure_barriers (none) [note is array/list, not hash]
#   %elementAttributes (none)
#   %isCDATA_Parent (none)

=head1 VARIABLES

Note that none of these variables are exported.

=head2 hashset %HTML::Tagset::emptyElement

This hashset has as values the tag-names (GIs) of elements that cannot
have content (children). (For example, "base", "br", "hr".)  So
C<$HTML::Tagset::emptyElement{'hr'}> exists and is true.
C<$HTML::Tagset::emptyElement{'dl'}> does not exist, and so is not true.

=cut

%emptyElement   = map {; $_ => 1 } qw(
  base link meta isindex
  img br hr wbr
  input area param
  embed bgsound spacer
  basefont col frame
  ~comment ~literal
  ~declaration ~pi
);
# The "~"-initial names are for pseudo-elements used by HTML::Entities
#  and TreeBuilder

=head2 hashset %HTML::Tagset::optionalEndTag

This hashset lists tag-names for elements that can have content, but whose
end-tags are generally, "safely", omittable.  Example:
C<$HTML::Tagset::emptyElement{'li'}> exists and is true.

=cut

%optionalEndTag = map {; $_ => 1 } qw(
  p li dt dd
  plaintext
); # option th tr td;

=head2 hash %HTML::Tagset::linkElements

Values in this hash are tagnames for elements that might contain
links, and the value for each is a reference to an array of the names
of attributes whose values can be links.

=cut

# TBD this list may need an update
%linkElements =
(
 'a'          => ['href'],
 'applet'     => ['archive', 'codebase', 'code'],
 'area'       => ['href'],
 'base'       => ['href'],
 'bgsound'    => ['src'],
 'blockquote' => ['cite'],
 'body'       => ['background'],
 'del'        => ['cite'],
 'embed'      => ['pluginspage', 'src'],
 'form'       => ['action'],
 'frame'      => ['src', 'longdesc'],
 'iframe'     => ['src', 'longdesc'],
 'ilayer'     => ['background'],
 'img'        => ['src', 'lowsrc', 'longdesc', 'usemap'],
 'input'      => ['src', 'usemap'],
 'ins'        => ['cite'],
 'isindex'    => ['action'],
 'head'       => ['profile'],
 'layer'      => ['background', 'src'],
 'link'       => ['href'],
 'object'     => ['classid', 'codebase', 'data', 'archive', 'usemap'],
 'q'          => ['cite'],
 'script'     => ['src', 'for'],
 'table'      => ['background'],
 'td'         => ['background'],
 'th'         => ['background'],
 'tr'         => ['background'],
 'xmp'        => ['href'],
);

=head2 hash %HTML::Tagset::boolean_attr

This hash (not hashset) lists what attributes of what elements can be
printed without showing the value (for example, the "noshade" attribute
of "hr" elements).  For elements with only one such attribute, its value
is simply that attribute name.  For elements with many such attributes,
the value is a reference to a hashset containing all such attributes.

=cut

%boolean_attr = (
  'area'   => { 'nohref' => 1 },
  'dir'    => { 'compact' => 1 },
  'dl'     => { 'compact' => 1 },
  'hr'     => { 'noshade' => 1 },
  'img'    => { 'ismap' => 1 },
  'input'  => { 'checked' => 1, 'readonly' => 1, 'disabled' => 1 },
  'menu'   => { 'compact' => 1 },
  'ol'     => { 'compact' => 1 },
  'option' => { 'selected' => 1 },
  'select' => { 'multiple' => 1 },
  'td'     => { 'nowrap' => 1 },
  'th'     => { 'nowrap' => 1 },
  'ul'     => { 'compact' => 1, 'reversed' => 1 },
);

#==========================================================================
# List of all elements from Extensible HTML version 1.0 Transitional DTD:
#
#   a abbr acronym address applet area b base basefont bdo big
#   blockquote body br button caption center cite code col colgroup
#   dd del dfn dir div dl dt em fieldset font form h1 h2 h3 h4 h5 h6
#   head hr html i iframe img input ins isindex kbd label legend li
#   link map menu meta noframes noscript object ol optgroup option p
#   param pre q s samp script select small span strike strong style
#   sub sup table tbody td textarea tfoot th thead title tr tt u ul
#   var
#
# Varia from Mozilla source internal table of tags:
#   Implemented:
#     xmp listing wbr nobr frame frameset noframes ilayer
#     layer nolayer spacer embed multicol
#   But these are unimplemented:
#     sound??  keygen??  server??
# Also seen here and there:
#     marquee??  app??  (both unimplemented)
#==========================================================================
# TBD list of all HTML 5 tags at this time, per way2tutorial.com/html/tag,
#     w3schools.com/tags, and "HTML for the World Wide Web" (E. Castro),
#     html.com/tags, developer.mozilla.org/en-US/docs/Web/HTML/Element,
#     tutorialspoint.com/html, w3docs.com/learn-html
#
#  a, abbr, address, area, article, aside, audio, b, base, basefont, bdi, bdo,
#  bgsound, big, blink, blockquote, body, br, button, canvas, caption, center,
#  cite, code, col, colgroup, command, data, datalist, dd,
#  del, details, dfn, dialog, dir, div, dl, dt, em, embed, fieldset, 
#  figcaption, figure, font, footer, form, frame, frameset, h1-6, head, header, 
#  hgroup, hr, html, i, iframe, img, input, ins, kbd, keygen, label, legend, 
#  li, link, main, map, mark, marquee, menu, meta, meter, nav, noframes, 
#  noscript, object, ol, optgroup, option, output, p, param, picture, pre, 
#  progress, q, rp, rt, ruby, s, samp, script, search, section, select, small, 
#  source, span, strike, strong, style, sub, summary, sup, svg, table, tbody, 
#  td, template, textarea, tfoot, th, thead, time, title, tr, track, tt, u, ul, 
#  var, video, wbr, !doctype, !-- comment
#
# In HTML 5 and then removed:
#  bb, datagrid, eventsource
# Netscape-only extension:
#  layer, ilayer, nolayer
# Never quite standardized:
#  nobr (use CSS white-space)
# Very obsolete:
#  acronym (use abbr), applet (use audio/video/embed/object), isindex,
#  listing (use code), multicol (use CSS columns), spacer, xmp (use pre or code)
# I swear I have seen these before, but can't find any refs discussing them: 
#  bigger, smaller
# Can't find anything on:
#  sound (use audio?), server, app
# 
# Need to 1) include/exclude per desired HTML version (obsolete/removed tags)
#         2) distribute among head-only, body-only, head+body, phrasal
#            (inline), block, and who is child of whom (e.g., table) lists
#         3) semantic and descriptive markup lists?
#         4) attributes for tags?

=head2 hashset %HTML::Tagset::isHeadOrBodyElement

This hashset includes all elements that I notice can fall either in
the head or in the body.

=cut

%isHeadOrBodyElement = map {; $_ => 1 } qw(
  script noscript 
  isindex 
  style
);
# i.e., if we find 'script' in the 'body' or the 'head', don't freak out.

=head2 hashset %HTML::Tagset::isBlockElement

This hashset contains all block-level elements.

=cut

# courtesy of stas@sysd.org, via RT 74627
# source: http://en.wikipedia.org/wiki/HTML_element#Block_elements
%isBlockElement = map {; $_ => 1 } qw(
  p
  h1 h2 h3 h4 h5 h6
  hgroup
  dl dt dd
  ol ul li
  dir menu
  map area
  address
  blockquote
  center
  div
  hr
  marquee
  noscript script
  frameset frame noframes
  form
  pre
  table thead tbody tfoot tr caption
  template details dialog
  audio video
  figure figcaption
  summary section article header footer aside main
  search 
  multicol layer nolayer 
  bgsound applet
);
# note that <br> breaks a line, but is not considered a block element
# TBD do children of <table> belong here? ditto for <li> under lists.

=head2 hashset %HTML::Tagset::isPhraseMarkup

This hashset contains all phrasal-level ("in line") elements.

=cut

%isPhraseMarkup = map {; $_ => 1 } qw(
  span abbr acronym q sub sup
  cite code em kbd samp strong var dfn strike
  b i u s tt small big 
  ins del
  a br nobr
  img svg 
  wbr blink
  font basefont bdo bdi
  spacer embed noembed
  button canvas command
  data select textarea
  iframe mark meter progress
  nav picture 
  object param
  ruby time
  plaintext xmp listing
  ilayer
); 
# TBD td, th, col, colgroup? can't appear outside a table. some of the list
#   must be children of another tag, e.g., form -> select, textarea
# TBD label, legend? are these intended to be anything non-block that can 
#   appear in the <body>, yet not required to be a child of another tag?

=head2 hashset %HTML::Tagset::isFormElement

This hashset contains all elements that are to be found only in/under
a "form" element.

=cut

%isFormElement  = map {; $_ => 1 } qw(
  input 
  select optgroup 
  option
  textarea 
  button 
  label
  fieldset
  legend
  datalist
  output
  keygen
);

=head2 hashset %HTML::Tagset::is_Possible_Strict_P_Content

This hashset contains all phrasal-level elements that be content of a
P element, for a strict model of HTML.

=cut

%is_Possible_Strict_P_Content = (
  %isPhraseMarkup,
  %isFormElement,
  map {; $_ => 1} qw(
    object script map
  ),
  # I've no idea why there's these latter exceptions.
  # I'm just following the HTML4.01 DTD.
);

#from html4 strict:
#<!ENTITY % fontstyle "TT | I | B | BIG | SMALL">
#
#<!ENTITY % phrase "EM | STRONG | DFN | CODE |
#                   SAMP | KBD | VAR | CITE | ABBR | ACRONYM" >
#
#<!ENTITY % special
#   "A | IMG | OBJECT | BR | SCRIPT | MAP | Q | SUB | SUP | SPAN | BDO">
#
#<!ENTITY % formctrl "INPUT | SELECT | TEXTAREA | LABEL | BUTTON">
#
#<!-- %inline; covers inline or "text-level" elements -->
#<!ENTITY % inline "#PCDATA | %fontstyle; | %phrase; | %special; | %formctrl;">

=head2 hashset %HTML::Tagset::isHeadElement

This hashset contains all elements that elements that may be
present in the 'head' element of an HTML document. Some, such as <script>,
may also by in the 'body'.

=cut

%isHeadElement = (
  map {; $_ => 1 } qw(
    title 
    base basefont
    link 
    meta 
    object 
  ),
  %isHeadOrBodyElement,
);

=head2 hashset %HTML::Tagset::isList

This hashset contains all elements that can contain "li" elements.

=cut

%isList = map {; $_ => 1 } qw(
  ul ol 
  dir menu
);

=head2 hashset %HTML::Tagset::isTableElement

This hashset contains all elements that are to be found only in/under
a "table" element.

=cut

%isTableElement = map {; $_ => 1 } qw(
  tr td th 
  thead tbody tfoot 
  caption 
  col colgroup
);

# TBD there are some other parent-child relationships that might need to
# be specified:
#   audio, video -> source, track
#   dl -> dt, dd
#   ol, ul -> li
#   figure -> figcaption
#   form -> fieldset
#   select (form) -> optgroup
#   datalist (form) -> option
#   frameset -> frame
#   map -> area
#   object ->param
#   picture -> source
#   ruby -> rp, rt
# perhaps a general parent_children hash? mark a child as mandatory or optional,
# include table, form, list

=head2 hashset %HTML::Tagset::isBodyElement

This hashset contains all elements that are to be found only in/under
the "body" element of an HTML document.

=cut

%isBodyElement = (
 %isFormElement,
 %isBlockElement,
 %isPhraseMarkup,
 %isTableElement,
 %isHeadOrBodyElement,
);

=head2 hashset %HTML::Tagset::isKnown

This hashset lists all known HTML elements.

=cut

%isKnown = (
  map{; $_=>1 } qw( 
    head body html
    frame frameset noframes
    ~comment ~pi ~directive ~literal
  ),
  %isHeadElement, 
  %isBodyElement,
);
# that should be all known tags ever ever


=head2 hashset %HTML::Tagset::canTighten

This hashset lists elements that might have ignorable whitespace as
children or siblings.

=cut

%canTighten = %isKnown;
delete @canTighten{
  keys(%isPhraseMarkup), 
  'input', 
  'select',
  'xmp', 
  'listing', 
  'plaintext', 
  'pre',
};
  # xmp, listing, plaintext, and pre  are untightenable, and
  #   in a really special way.
@canTighten{'hr','br'} = (1,1);
 # exceptional 'phrasal' things that ARE subject to tightening.

# The one case where I can think of my tightening rules failing is:
#  <p>foo bar<center> <em>baz quux</em> ...
#                    ^-- that would get deleted.
# But that's pretty gruesome code anyhow.  You gets what you pays for.

#==========================================================================

=head2 array @HTML::Tagset::p_closure_barriers

This array has a meaning that I have only seen a need for in
C<HTML::TreeBuilder>, but I include it here on the off chance that someone
might find it of use:

When we see a "E<lt>pE<gt>" token, we go lookup up the lineage for a p
element we might have to minimize.  At first sight, we might say that
if there's a p anywhere in the lineage of this new p, it should be
closed.  But that's wrong.  Consider this document:

  <html>
    <head>
      <title>foo</title>
    </head>
    <body>
      <p>foo
        <table>
          <tr>
            <td>
               foo
               <p>bar
            </td>
          </tr>
        </table>
      </p>
    </body>
  </html>

The second p is quite legally inside a much higher p.

My formalization of the reason why this is legal, but this:

  <p>foo<p>bar</p></p>

isn't, is that something about the table constitutes a "barrier" to
the application of the rule about what p must minimize.

So C<@HTML::Tagset::p_closure_barriers> is the list of all such
barrier-tags.

=cut

@p_closure_barriers = qw(
  li blockquote
  ul ol menu dir
  dl dt dd
  td th tr table caption
  div
 );

# In an ideal world (i.e., XHTML) we wouldn't have to bother with any of this
# monkey business of barriers to minimization!

=head2 hash %HTML::Tagset::elementAttributes

These are all the element (tag) 'attributes'. 
Note that there is much overlap with the list 'HTML::Tagset::linkElements'. 

Also, some of these attributes are
considered obsolete (from very old HTML versions), and other attributes or
CSS may be preferred. This is B<not> a recommendation to I<use> all of these
attributes; they are listed here for completeness, as you may encounter them
when processing HTML because at one time or another they were (more or less)
widely used.

=cut

# per w3schools.com/tags/ref_attributes.asp, E. Castro, "HTML for the
# World Wide Web", developer.mozilla.org/en-US/docs/Web/HTML/Attributes
%elementAttributes =
(
 'a'          => ['download', 'href', 'hreflang', 'media', 'name', 'ping', 
	          'referrerpolicy', 'rel', 'shape', 'target', 'type'],
 'applet'     => ['archive', 'code', 'codebase', 'height', 'width'],
 'area'       => ['alt', 'coords', 'download', 'href', 'hreflang', 'media', 
	          'nohref', 'ping', 'referrerpolicy', 'rel', 'shape', 'target'],
 'audio'      => ['autoplay', 'controls', 'crossorigin', 'loop', 'muted', 
	          'onabort', 'oncanplay', 'oncanplaythrough', 
		  'ondurationchange', 'onemptied', 'onended', 'onerror', 
		  'onloadeddata', 'onloadedmetadata', 'onloadstart', 'onpause', 
		  'onplay', 'onplaying', 'onprogress', 'onratechange', 
		  'onseeked', 'onseeking', 'onstalled', 'onsuspend', 
		  'ontimeupdate', 'onvolumechange', 'onwaiting', 'preload', 
		  'src'],
 'base'       => ['href', 'target'],
 'basefont'   => ['color', 'font', 'size'],
 'bgsound'    => ['loop', 'src'],
 'blockquote' => ['cite'],
 'body'       => ['alink', 'background', 'bgcolor', 'leftmargin', 
	          'onafterprint', 'onbeforeprint', 'onbeforeunload', 'onerror', 
		  'onhashchange', 'onload', 'onoffline', 'ononline', 
		  'onpagehide', 'onpageshow', 'onpopstate', 'onresize', 
		  'onstorage', 'onunload', 'text', 'topmargin', 'vlink'],
 'br'         => ['clear'],
 'button'     => ['disabled', 'form', 'formaction', 'formmethod', 
	          'formnovalidate', 'formtarget', 'name', 'popovertarget', 
		  'popovertargetaction', 'type', 'value'],
 'canvas'     => ['height', 'width'],
 'caption'    => ['align'],
 'col'        => ['align', 'bgcolor', 'span', 'width'],
 'colgroup'   => ['align', 'bgcolor', 'span', 'valign', 'width'],
 'data'       => ['value'],
 'del'        => ['cite', 'datetime'],
 'details'    => ['ontoggle', 'open'],
 'dialog'     => ['open'],
 'div'        => ['align'],
 'embed'      => ['align', 'autostart', 'controls', 'height', 'loop', 'onabort',
	          'oncanplay', 'pluginspage', 'onerror', 'src', 'type', 
		  'width'],
 'fieldset'   => ['disabled', 'form', 'name'],
 'font'       => ['color', 'face', 'size'],
 'form'       => ['accept', 'accept-charset', 'action', 'autocomplete', 
	          'enctype', 'method', 'name', 'novalidate', 'onreset', 
		  'onsubmit', 'rel', 'target'],
 'frame'      => ['border', 'bordercolor', 'frameborder', 'framespacing', 
	          'longdesc', 'name', 'noresize', 'marginwidth', 'marginheight',
		  'scrolling', 'src', 'target'],
 'frameset'   => ['border', 'bordercolor', 'cols', 'frameborder', 
	          'framespacing', 'rows'],
 'h1'         => ['align'],
 'h2'         => ['align'],
 'h3'         => ['align'],
 'h4'         => ['align'],
 'h5'         => ['align'],
 'h6'         => ['align'],
 'hr'         => ['align', 'color', 'noshade', 'size', 'width'],
 'html'       => ['manifest'],
 'iframe'     => ['align', 'allow', 'csp', 'frameborder', 'height', 'loading', 
	          'longdesc', 'name', 'onload', 'referrerpolicy', 'sandbox', 
		  'scrolling', 'src', 'srcdoc', 'width'],
 'ilayer'     => ['background'],
 'img'        => ['align', 'alt', 'border', 'crossorigin', 'decoding', 'height',
	          'hspace', 'intrinsicsize', 'ismap', 'loading', 'lowsrc', 
		  'longdesc', 'onabort', 'onerror', 'onload', 'referrerpolicy', 
		  'sizes', 'src', 'srcset', 'usemap', 'vspace', 'width'],
 'input'      => ['accept', 'align', 'alt', 'autocomplete', 'capture', 
	          'checked', 'dirname', 'disabled', 'form', 'formaction', 
		  'formmethod', 'formnovalidate', 'formtarget', 'height', 
		  'list', 'max', 'maxlength', 'min', 'minlength', 'multiple', 
		  'name', 'novalidate', 'onload', 'onsearch', 'pattern', 
		  'placeholder', 'popovertarget', 'popovertargetaction', 
		  'readonly', 'required', 'size', 'src', 'step', 'type', 
		  'usemap', 'value', 'width'],
 'ins'        => ['cite', 'datetime'],
 'isindex'    => ['action'],
 'head'       => ['profile'],
 'label'      => ['for', 'form'],
 'layer'      => ['background', 'src'],
 'legend'     => ['align'],
 'li'         => ['type', 'value'],
 'link'       => ['as', 'crossorigin', 'href', 'hreflang', 'integrity', 'media',
	          'onload', 'referrerpolicy', 'rel', 'sizes', 'type'],
 'map'        => ['name'],
 'marquee'    => ['behavior', 'bgcolor', 'direction', 'loop', 'scrollamount', 
	          'scrolldelay'],
 'menu'       => ['type'],
 'meta'       => ['charset', 'content', 'http-equiv', 'name'],
 'meter'      => ['form', 'high', 'low', 'max', 'min', 'optimum', 'value'],
 'object'     => ['align', 'archive', 'border', 'classid', 'codebase', 'data', 
	          'form', 'height', 'hspace', 'name', 'onabort', 'oncanplay', 
		  'onerror', 'type', 'usemap', 'vspace', 'width'],
 'ol'         => ['reversed', 'start', 'type'],
 'optgroup'   => ['disabled', 'label'],
 'option'     => ['disabled', 'label', 'selected', 'value'],
 'output'     => ['for', 'form', 'name'],
 'p'          => ['align'],
 'param'      => ['name', 'value'],
 'progress'   => ['form', 'max', 'value'],
 'q'          => ['cite'],
 'script'     => ['async', 'charset', 'crossorigin', 'defer', 'for', 
	          'integrity', 'language', 'onerror', 'onload', 
		  'referrerpolicy', 'src', 'type'],
 'select'     => ['autocomplete', 'disabled', 'form', 'multiple', 'name', 
	          'required', 'selected', 'size'],
 'source'     => ['media', 'sizes', 'src', 'srcset', 'type'],
 'style'      => ['media', 'onerror', 'onload', 'scoped', 'type'],
 'table'      => ['align', 'background', 'bgcolor', 'border', 'bordercolor',
                  'bordercolordark', 'bordercolorlight', 'cellpadding',
	          'cellspacing', 'frame', 'height', 'rules', 'summary', 
		  'width'],
 'tbody'      => ['align', 'bgcolor'],
 'td'         => ['align', 'background', 'bgcolor', 'char', 'colspan', 
	          'headers', 'height', 'nowrap', 'rowspan', 'width'],
 'textarea'   => ['autocomplete', 'cols', 'dirname', 'disabled', 'form', 
	          'inputmode', 'maxlength', 'minlength', 'name', 'placeholder', 
		  'readonly', 'required', 'rows', 'wrap'],
 'tfoot'      => ['align', 'bgcolor', 'valign'],
 'th'         => ['align', 'background', 'bgcolor', 'char', 'colspan', 
	          'headers', 'height', 'nowrap', 'rowspan', 'scope', 'width'],
 'thead'      => ['align', 'valign'],
 'time'       => ['datetime'],
 'tr'         => ['align', 'background', 'bgcolor', 'valign'],
 'track'      => ['default', 'kind', 'label', 'oncuechange', 'src', 'srclang'],
 'ul'         => ['type'],
 'video'      => ['autoplay', 'controls', 'crossorigin', 'height', 'loop', 
	          'muted', 'onabort', 'oncanplay', 'oncanplaythrough', 
		  'ondurationchange', 'onemptied', 'onended', 'onerror', 
		  'onloadeddata', 'onloadedmetadata', 'onloadstart', 'onpause', 
		  'onplay', 'onplaying', 'onprogress', 'onratechange', 
		  'onseeked', 'onseeking', 'onstalled', 'onsuspend', 
		  'ontimeupdate', 'onvolumechange', 'onwaiting', 'playsinline', 
		  'poster', 'preload', 'src', 'width'],
 'xmp'        => ['href'],
);
# Global Attributes: 'accesskey', 'autocapitalize', 'class', 'contenteditable', 
#     'contextmenu', 'data-*', 'dir', 'draggable', 'enterkeyhint', 'hidden', 
#     'id', 'inert', 'inputmode', 'itemprop', 'lang', 'popover', 'role', 'slot',
#     'spellcheck', 'style', 'tabindex', 'title', 'translate'
# Global for all visible elements: 'onblur', 'onchange', 'onclick', 
#     'oncontextmenu', 'oncopy', 'oncut', 'ondblclick', 'ondrag', 'ondragend',
#     'ondragenter', 'ondragleave', 'ondragover', 'ondragstart', 'ondrop',
#     'onfocus', 'oninput', 'oninvalid', 'onkeydown', 'onkeypress', 'onkeyup',
#     'onmousedown', 'onmousemove', 'onmouseout', 'onmouseover', 'onmouseup,
#     'onmousewheel', 'onpaste', 'onscroll', 'onselect', 'onwheel'
# Global (?) Attributes removed from HTML 5: 'align', 'bgcolor', 'border', 
#     'color', 'contenteditable'

=head2 hashset %isCDATA_Parent

This hashset includes all elements whose content is CDATA.

=cut

%isCDATA_Parent = map {; $_ => 1 } qw(
  script style  
  xmp listing plaintext
);

# TODO: there's nothing else that takes CDATA children, right?

# As the HTML3 DTD (Raggett 1995-04-24) noted:
#   The XMP, LISTING and PLAINTEXT tags are incompatible with SGML
#   and derive from very early versions of HTML. They require non-
#   standard parsers and will cause problems for processing
#   documents with standard SGML tools.


=head1 CAVEATS

You may find it useful to alter the behavior of modules (like
C<HTML::Element> or C<HTML::TreeBuilder>) that use C<HTML::Tagset>'s
data tables by altering the data tables themselves.  You are welcome
to try, but be careful; and be aware that different modules may or may
react differently to the data tables being changed.

Note that it may be inappropriate to use these tables for I<producing>
HTML -- for example, C<%isHeadOrBodyElement> lists the tagnames
for all elements that can appear either in the head or in the body,
such as "script".  That doesn't mean that I am saying your code that
produces HTML should feel free to put script elements in either place!
If you are producing programs that spit out HTML, you should be
I<intimately> familiar with the DTDs for HTML or XHTML (available at
C<http://www.w3.org/>), and you should slavishly obey them, not
the data tables in this document.

=head1 SEE ALSO

L<HTML::Element>, L<HTML::TreeBuilder>, L<HTML::LinkExtor>

=head1 COPYRIGHT & LICENSE

Copyright 1995-2000 Gisle Aas.

Copyright 2000-2005 Sean M. Burke.

Copyright 2005-2019 Andy Lester.

This library is free software; you can redistribute it and/or modify it
under the terms of the Artistic License version 2.0.

=head1 ACKNOWLEDGEMENTS

Most of the code/data in this module was adapted from code written
by Gisle Aas for C<HTML::Element>, C<HTML::TreeBuilder>, and
C<HTML::LinkExtor>.  Then it was maintained by Sean M. Burke.

=head1 AUTHOR

Current maintainer: Andy Lester, C<< <andy at petdance.com> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-html-tagset at rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=HTML-Tagset>.  I will
be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=cut

1;
