#Form Controls
A form controls utility for [Symphony](http://symphony-cms.com)

## What is it?


## Download
Form Controls (form-controls.xsl) is a single XSLT file and can be downloaded from the Symphony XSLT Utilities site:

<http://symphony21.com/downloads/xslt/file/...>

## Installing the utility
Add the `form-controls.xsl` file to your `/workspace/utilities` folder alongside the [other cool XSLT utilities](http://symphony21.com/downloads/xslt/) you know and love.

On the page in which you are building the form, import the XSL file:

	<xsl:import href="../utilities/form-controls.xsl"/>

Form Controls uses some functions not available to XSLT 1.0, therefore you will need to have the [EXSLT library](http://exslt.org/) installed (you should do already) and you will need to add the EXSLT namespace to your page. Additionally Form Controls adds all templates and variables to `form` namespace so as not to class with other templates in your website. After including these two required namespaces your page `stylesheet` element should look something like this:

	<xsl:stylesheet	version="1.0"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:exsl="http://exslt.org/common"
		xmlns:form="http://nick-dunn.co.uk/xslt/form-controls"
		extension-element-prefixes="exsl form">

The `extension-element-prefixes` attributes prevents these namespaces being added to your HTML elements when the page is rendered.

## Supported form controls
Form Controls supports all field types native to Symphony (input, textarea, select) and adds a few of its own too. It can generate the following:

* Label
* Input (text, password, file)
* Textarea
* Checkbox
* Radio
* Select (including multi-select)
* Radiobutton List
* Checkbox List
* Validation Summary (list of error messages)

Form Controls assumes you are submitting to a front-end event in Symphony. In the examples below I will outline the basic structure of the section that the event derives from. For brevity I assume that your pages include a `master.xsl` which outputs the page header/footer.

## Most basic example
Submits to an event (`save-post`) derived from a Posts section. Create a new page and attach the `Save Post` event to it. Paste the following XSLT into your page replacing the default contents:

	<?xml version="1.0" encoding="UTF-8"?>
	<xsl:stylesheet	version="1.0"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:exsl="http://exslt.org/common"
		xmlns:form="http://nick-dunn.co.uk/xslt/form-controls"
		extension-element-prefixes="exsl form">

	<xsl:import href="../utilities/master.xsl"/>

	<!-- Import form-controls.xsl -->
	<xsl:import href="../utilities/form-controls.xsl"/>

	<!-- Define a global variable referring to your Event -->
	<xsl:variable name="form:event" select="/data/events/save-blog-post"/>

	<xsl:template match="data">
	
		<form action="" method="post">
		
			<fieldset>
				<legend>Create new post</legend>

				<xsl:call-template name="form:validation-summary"/>

				<label>
					Post title<br/>
					<xsl:call-template name="form:input">
						<xsl:with-param name="handle" select="'title'"/>
					</xsl:call-template>
				</label>

				<label>
					Post contents<br/>
					<xsl:call-template name="form:textarea">
						<xsl:with-param name="handle" select="'content'"/>
					</xsl:call-template>
				</label>

			</fieldset>
		
		</form>
	
	</xsl:template>
	
	</xsl:stylesheet>

This will generate HTML akin to the following (just the `fieldset` included, my indenting):

	<fieldset>
		<legend>Create new post</legend>
		<label>
			Post title<br />
			<input name="fields[title]" id="fields-title" title="" class="" type="text" value="" />
		</label>
		<label>
			Post contents<br />
			<textarea name="fields[content]" id="fields-content" title="" class=""></textarea>
		</label>
	</fieldset>
	
On form submit you will also receive a validation summary — either a success message, or a list of missing or invalid fields.

## Template examples
Here are examples outlining the full range of options. Additional information regarding each template and its parameters can be gleaned from the source.

### form:event
This variable should be created globally, outside of your page templates. It should select the event node created by the event you are posting to.

	<xsl:variable name="form:event" select="/data/events/save-blog-post"/>

### form:label
Renders an HTML `label` element that can be explicitly assigned to another form element. Can be wrapped around other controls.

#### Parameters

* *for* (optional, string): Handle of a Symphony field name that this label is associated with
* *text* (optional, string): Text value of the label. Defaults to field name ($for value)
* *child* (optional, XML): Places this XML inside the label, for wrapping elements with the label
* *child-position* (optional, string): Place the child before or after the label text. Defaults to "after"
* *class* (optional, string): Value of the HTML @class attribute
* *section* (optional, string): Use with EventEx to change "fields[...]" to a section handle
* *event* (optional, XPath): XPath expression to the specific event within the page <events> node

#### Example

	<xsl:call-template name="form:label">
		<xsl:with-param name="for" select="'title'"/>
	</xsl:call-template>


	<xsl:call-template name="form:label">
		<xsl:with-param name="for" select="'title'"/>
		<xsl:with-param name="text" select="'Post Title'"/>
		<xsl:with-param name="child">
			<xsl:call-template name="form:input">
				<xsl:with-param name="handle" select="'title'"/>
			</xsl:call-template>
		</xsl:with-param>
	</xsl:call-template>

### form:input
Renders an HTML text `input` element with support for `password` and `file` types.

#### Parameters

* *handle* (mandatory, string): Handle of the field name
* *value* (optional, string): Initial value of form control. Will not work for `file` inputs.
* *type* (optional, string): Type attribute value ("text", "password" "file"). Defaults to "text"
* *class* (optional, string): Class attribute value
* *title* (optional, string): Title attribute value
* *size* (optional, string): Size attribute value
* *maxlength* (optional, string): Maxlength attribute value
* *autocomplete* (optional, string): Autocomplete attribute value ("off"). Not set by default
* *section* (optional, string): Use with EventEx to change "fields[...]" to a section handle
* *event* (optional, XPath): XPath expression to the specific event within the page <events> node
	
#### Example

	<xsl:call-template name="form:input">
		<xsl:with-param name="handle" select="'title'"/>
		<xsl:with-param name="value" select="'My first blog post'"/>
	</xsl:call-template>

	<xsl:call-template name="form:input">
		<xsl:with-param name="handle" select="'image'"/>
		<xsl:with-param name="type" select="'file'"/>
		<xsl:with-param name="title" select="'Please upload an image'"/>
	</xsl:call-template>

### form:textarea
Renders an HTML `textarea` element. 

#### Parameters

* *handle* (mandatory, string): Handle of the field name
* *value* (optional, string): Contents of the textarea
* *class* (optional, string): Class attribute value
* *rows* (optional, string): Rows attribute value
* *cols* (optional, string): cols attribute value
* *section* (optional, string): Use with EventEx to change "fields[...]" to a section handle
* *event* (optional, XPath): XPath expression to the specific event within the page <events> node

#### Example

	<xsl:call-template name="form:textarea">
		<xsl:with-param name="handle" select="'content'"/>
		<xsl:with-param name="rows" select="'5'"/>
		<xsl:with-param name="cols" select="'40'"/>
	</xsl:call-template>

### form:checkbox
Renders an HTML checkbox `input` element. If a checkbox is not checked, its value is never sent in the POST array to the event. For this reason a hidden field with the same name, and a value of "no" will be rendered just before the checkbox. Ticking the checkbox will override this "no" value.

#### Parameters

* *handle* (mandatory, string): Handle of the field name
* *checked* (optional, string): Initial checked state ("yes", "no"). Defaults to "no"
* *checked-by-default* (optional, string): When there is no initial $checked value (a fresh form), check by default ("yes", "no"). Defaults to "no"
* *class* (optional, string): Class attribute value
* *title* (optional, string): Title attribute value
* *section* (optional, string): Use with EventEx to change "fields[...]" to a section handle
* *event* (optional, XPath): XPath expression to the specific event within the page <events> node
* *allow-multiple* (optional, string): Internal use only ("yes", "no"). Whether checkbox is part of a checkbox list. Defaults to "no"
* *allow-multiple-value* (optional, string): Internal use only. Overrides default "yes" value when part of a checkbox list

#### Example
	
	<!-- renders a checkbox (ticked), inside a label with the label text following the checkbox -->
	<xsl:call-template name="form:label">
		<xsl:with-param name="for" select="'published'"/>
		<xsl:with-param name="text" select="'Publish this post'"/>
		<xsl:with-param name="child">
			<xsl:call-template name="form:checkbox">
				<xsl:with-param name="handle" select="'published'"/>
				<xsl:with-param name="checked-by-default" select="'yes'"/>
			</xsl:call-template>
		</xsl:with-param>
		<xsl:with-param name="child-position" select="'before'"/>
	</xsl:call-template>

### form:radio
Renders an HTML radio `input` element. Could be used to save values to an Input or Select Box field.

#### Parameters

* *handle* (mandatory, string): Handle of the field name
* *value* (optional, string): The selected value for this radio sent when the form is submitted
* *existing-value* (optional, string): An initial value. Selects radio if it matches $value
* *checked-by-default* (optional, string): When there is no initial $existing-value (a fresh form), select by default ("yes", "no"). Defaults to "no"
* *class* (optional, string): Class attribute value
* *title* (optional, string): Title attribute value
* *type* (optional, string): Internal use only ("radio", "checkbox"). Defaults to "radio"
* *section* (optional, string): Use with EventEx to change "fields[...]" to a section handle
* *event* (optional, XPath): XPath expression to the specific event within the page <events> node
* *allow-multiple* (optional, string): Internal use only ("yes", "no"). Whether control is part of a radio/checkbox list. Defaults to "no"

#### Example

	<!-- allow selection from two options -->
	<xsl:call-template name="form:label">
		<xsl:with-param name="text" select="'Choose Option 1?'"/>
		<xsl:with-param name="child">
			<xsl:call-template name="form:radio">
				<xsl:with-param name="handle" select="'option'"/>
				<xsl:with-param name="value" select="'Option 1'"/>
				<xsl:with-param name="checked-by-default" select="'yes'"/>
			</xsl:call-template>
		</xsl:with-param>
		<xsl:with-param name="child-position" select="'before'"/>
	</xsl:call-template>
	
	<xsl:call-template name="form:label">
		<xsl:with-param name="text" select="'Choose Option 2?'"/>
		<xsl:with-param name="child">
			<xsl:call-template name="form:radio">
				<xsl:with-param name="handle" select="'option'"/>
				<xsl:with-param name="value" select="'Option 2'"/>
			</xsl:call-template>
		</xsl:with-param>
		<xsl:with-param name="child-position" select="'before'"/>
	</xsl:call-template>

### form:select
Renders an HTML `select` element. Has several presets to build commonly-used sets of options, and supports many formats to create additional options.

#### Parameters

* *handle* (mandatory, string): Handle of the field name
* *options* (mandatory, XPath/XML): Options to build a list of <option> elements. Has presets! See examples.
* *value* (optional, string): Initial selected value
* *class* (optional, string): Class attribute value
* *title* (optional, string): Title attribute value
* *section* (optional, string): Use with EventEx to change "fields[...]" to a section handle
* *event* (optional, XPath): XPath expression to the specific event within the page <events> node
* *allow-multiple* (optional, string): Internal use only ("yes", "no"). Whether control is beung used to generate a radio/checkbox list. Defaults to "no"

#### Examples



## Multiple forms per page

## Submitting to multiple sections (EventEx)

## Building a form automatically (Section Schemas)