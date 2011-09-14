<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
	version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:exsl="http://exslt.org/common"
	xmlns:form="http://nick-dunn.co.uk/xslt/form-controls"
	extension-element-prefixes="exsl form">

<!--
Name: Form Controls
Description: An XSLT utility to create powerful HTML forms with Symphony
Version: 1.6
Author: Nick Dunn <http://github.com/nickdunn>
URL: http://github.com/nickdunn/form-controls/tree/master
-->

<!-- Class valid added to invalid form controls -->
<xsl:variable name="form:invalid-class" select="'invalid'"/>

<!--
Name: validation-summary
Description: Renders a success/error message and list of invalid fields
Returns: HTML
Parameters:
* `error-message` (optional, string/XPath): Error notification message. Defaults to Symphony Event message
* `success-message` (optional, string/XPath): Success notification message. Defaults to Symphony Event message
* `errors` (optional, XML): Custom error messages for individual fields as <error> nodes. Defaults to Symphony Event defaults
* `section` (optional, string): Use with EventEx to show errors for a specific section handle only
* `event` (optional, XPath): XPath expression to the specific event within the page <events> node
-->
<xsl:template name="form:validation-summary">
	<xsl:param name="event" select="$form:event"/>
	<xsl:param name="error-message" select="$event/message"/>
	<xsl:param name="success-message" select="$event/message"/>
	<xsl:param name="errors"/>
	<xsl:param name="section" select="'fields'"/>
	
	<xsl:variable name="index-key">
		<xsl:call-template name="form:section-index-key">
			<xsl:with-param name="section" select="$section"/>
		</xsl:call-template>
	</xsl:variable>
	
	<xsl:variable name="section-handle">
		<xsl:call-template name="form:section-handle">
			<xsl:with-param name="section" select="$section"/>
		</xsl:call-template>
	</xsl:variable>
	
	<xsl:variable name="event-result">
		<xsl:choose>
			<xsl:when test="$section!='fields' and $index-key!=''">
				<xsl:copy-of select="$event//entry[@section-handle=$section-handle and @index-key=$index-key]"/>
			</xsl:when>
			<xsl:when test="$section!='fields'">
				<xsl:copy-of select="$event//entry[@section-handle=$section-handle]"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy-of select="$event"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	
	<xsl:choose>
		<xsl:when test="exsl:node-set($event-result)//*[@result='error']">
			
			<div class="validation-summary error">

				<xsl:choose>
					<xsl:when test="exsl:node-set($error-message)/*">
						<xsl:copy-of select="$error-message"/>
					</xsl:when>
					<xsl:otherwise>
						<p><xsl:value-of select="$error-message"/></p>
					</xsl:otherwise>
				</xsl:choose>

				<ul>
					<xsl:for-each select="exsl:node-set($event-result)//*[not(name()='entry') and @type]">
						<li>
							<label>
								<xsl:attribute name="for">
									<xsl:choose>
										<xsl:when test="parent::entry/@index-key">
											<xsl:value-of select="concat(parent::entry/@section-handle,'-',parent::entry/@index-key,'-',name())"/>
										</xsl:when>
										<xsl:when test="parent::entry">
											<xsl:value-of select="concat(parent::entry/@section-handle,'-',name())"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="concat('fields-',name())"/>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:attribute>

								<xsl:choose>
									
									<!-- @message and a section specified -->
									<xsl:when test="@message and exsl:node-set($errors)/error[@handle=name(current()) and @message=current()/@message and @section=current()/parent::entry/@section-handle]">
										<xsl:call-template name="form:validation-label">
											<xsl:with-param name="label" select="exsl:node-set($errors)/error[@handle=name(current()) and @message=current()/@message and @section=current()/parent::entry/@section-handle]"/>
										</xsl:call-template>
									</xsl:when>
									<!-- missing -->
									<xsl:when test="@message and exsl:node-set($errors)/error[@handle=name(current()) and string(@message)=string(current()/@message)]">
										<xsl:call-template name="form:validation-label">
											<xsl:with-param name="label" select="exsl:node-set($errors)/error[@handle=name(current()) and @message=current()/@message]"/>
										</xsl:call-template>
									</xsl:when>
									
									<!-- missing and a section specified -->
									<xsl:when test="@type='missing' and exsl:node-set($errors)/error[@handle=name(current()) and contains(@type,'missing') and @section=current()/parent::entry/@section-handle]">
										<xsl:call-template name="form:validation-label">
											<xsl:with-param name="label" select="exsl:node-set($errors)/error[@handle=name(current()) and contains(@type,'missing') and @section=current()/parent::entry/@section-handle]"/>
										</xsl:call-template>
									</xsl:when>
									<!-- missing -->
									<xsl:when test="@type='missing' and exsl:node-set($errors)/error[@handle=name(current()) and contains(@type,'missing')]">
										<xsl:call-template name="form:validation-label">
											<xsl:with-param name="label" select="exsl:node-set($errors)/error[@handle=name(current()) and contains(@type,'missing')]"/>
										</xsl:call-template>
									</xsl:when>

									<!-- invalid and a section specified-->
									<xsl:when test="@type='invalid' and exsl:node-set($errors)/error[@handle=name(current()) and contains(@type,'invalid') and @section=current()/parent::entry/@section-handle]">
										<xsl:call-template name="form:validation-label">
											<xsl:with-param name="label" select="exsl:node-set($errors)/error[@handle=name(current()) and contains(@type,'invalid') and @section=current()/parent::entry/@section-handle]"/>
										</xsl:call-template>
									</xsl:when>
									<!-- invalid -->
									<xsl:when test="@type='invalid' and exsl:node-set($errors)/error[@handle=name(current()) and contains(@type,'invalid')]">
										<xsl:call-template name="form:validation-label">
											<xsl:with-param name="label" select="exsl:node-set($errors)/error[@handle=name(current()) and contains(@type,'invalid')]"/>
										</xsl:call-template>
									</xsl:when>
									
									<!-- no specific type match, section specified -->
									<xsl:when test="exsl:node-set($errors)/error[@handle=name(current()) and not(@type) and @section=current()/parent::entry/@section-handle]">
										<xsl:call-template name="form:validation-label">
											<xsl:with-param name="label" select="exsl:node-set($errors)/error[@handle=name(current()) and @section=current()/parent::entry/@section-handle]"/>
										</xsl:call-template>
									</xsl:when>
									<!-- no specific type match -->
									<xsl:when test="exsl:node-set($errors)/error[@handle=name(current()) and not(@type) and not(@message)]">
										<xsl:call-template name="form:validation-label">
											<xsl:with-param name="label" select="exsl:node-set($errors)/error[@handle=name(current())]"/>
										</xsl:call-template>
									</xsl:when>
									
									<xsl:when test="@message">
										<xsl:value-of select="@message"/>
									</xsl:when>
									
									<xsl:otherwise>
										<span class="field-name">
											<xsl:value-of select="translate(name(),'-',' ')"/>
										</span>
										<xsl:text> is </xsl:text>
										<xsl:value-of select="@type"/>
									</xsl:otherwise>

								</xsl:choose>								
							</label>
						</li>
					</xsl:for-each>
				</ul>

			</div>
			
		</xsl:when>
		
		<xsl:when test="exsl:node-set($event-result)//*[@result='success']">
		
			<div class="validation-summary success">
				<xsl:choose>
					<xsl:when test="exsl:node-set($success-message)/*">
						<xsl:copy-of select="$success-message"/>
					</xsl:when>
					<xsl:otherwise>
						<p><xsl:value-of select="$success-message"/></p>
					</xsl:otherwise>
				</xsl:choose>
			</div>
			
		</xsl:when>
	</xsl:choose>

</xsl:template>

<xsl:template name="form:validation-label">
	<xsl:param name="label"/>
	<xsl:choose>
		<xsl:when test="$label/*">
			<xsl:copy-of select="$label/text() | $label/*"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="$label"/>
		</xsl:otherwise>
	</xsl:choose>	
</xsl:template>

<!--
Name: form:label
Description: Renders an HTML `label` element that can be explicitly assigned to another form element. Can be wrapped around other controls.
Returns: HTML <label> element
Parameters:
* `for` (optional, string): Handle of a Symphony field name that this label is associated with
* `text` (optional, string): Text value of the label. Defaults to field name ($for value)
* `child` (optional, XML): Places this XML inside the label, for wrapping elements with the label
* `child-position` (optional, string): Place the child before or after the label text. Defaults to "after"
* `class` (optional, string): Value of the HTML @class attribute
* `section` (optional, string): Use with EventEx to change "fields[...]" to a section handle
* `event` (optional, XPath): XPath expression to the specific event within the page <events> node
-->
<xsl:template name="form:label">
	<xsl:param name="for"/>
	<xsl:param name="text"/>
	<xsl:param name="child"/>
	<xsl:param name="child-position" select="'after'"/>
	<xsl:param name="class"/>
	<xsl:param name="template"/>
	<xsl:param name="section" select="'fields'"/>
	<xsl:param name="event" select="$form:event"/>
	
	<xsl:param name="handle" select="$for"/>
	
	<xsl:element name="label" use-attribute-sets="form:attribute-class">
		
		<xsl:if test="$for">
			<xsl:attribute name="for">
				<xsl:call-template name="form:control-id">
					<xsl:with-param name="name">
						<xsl:call-template name="form:control-name">
							<xsl:with-param name="handle" select="$for"/>
							<xsl:with-param name="section" select="$section"/>
						</xsl:call-template>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:attribute>
		</xsl:if>
		
		<xsl:if test="$child and $child-position='before'">
			<xsl:copy-of select="$child"/>
		</xsl:if>
		
		<xsl:variable name="text">
			<xsl:choose>
				<xsl:when test="$text and $child">
					<xsl:value-of select="concat($text,' ')"/>
				</xsl:when>
				<xsl:when test="$text">
					<xsl:value-of select="$text"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="concat($for,' ')"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:choose>
			<xsl:when test="$template">
				<xsl:apply-templates select="exsl:node-set($template)" mode="form:replace-template">
					<xsl:with-param name="replacement" select="$text"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$text"/>
			</xsl:otherwise>
		</xsl:choose>
		
		<xsl:if test="$child and $child-position='after'">
			<xsl:copy-of select="$child"/>
		</xsl:if>
		
	</xsl:element>
	
</xsl:template>

<!--
Name: form:checkbox
Description: Renders an HTML checkbox `input` element
Returns: HTML <input> element
Parameters:
* `handle` (mandatory, string): Handle of the field name
* `checked` (optional, string): Initial checked state ("yes", "no"). Defaults to "no"
* `checked-by-default` (optional, string): When there is no initial $checked value (a fresh form), check by default ("yes", "no"). Defaults to "no"
* `class` (optional, string): Class attribute value
* `title` (optional, string): Title attribute value
* `section` (optional, string): Use with EventEx to change "fields[...]" to a section handle
* `event` (optional, XPath): XPath expression to the specific event within the page <events> node
* `allow-multiple` (optional, string): Internal use only ("yes", "no"). Whether checkbox is part of a checkbox list. Defaults to "no"
* `allow-multiple-value` (optional, string): Internal use only. Overrides default "yes" value when part of a checkbox list
-->
<xsl:template name="form:checkbox">
	<xsl:param name="handle"/>
	<xsl:param name="checked"/>
	<xsl:param name="checked-by-default" select="'no'"/>
	<xsl:param name="class"/>
	<xsl:param name="title"/>
	<xsl:param name="section" select="'fields'"/>
	<xsl:param name="event" select="$form:event"/>
	<xsl:param name="allow-multiple" select="'no'"/>
	<xsl:param name="allow-multiple-value"/>
	
	<xsl:if test="$allow-multiple='no'">
		<input type="hidden" value="no">
			<xsl:attribute name="name">
				<xsl:call-template name="form:control-name">
					<xsl:with-param name="handle" select="$handle"/>
					<xsl:with-param name="section" select="$section"/>
				</xsl:call-template>
			</xsl:attribute>
		</input>
	</xsl:if>
	
	<xsl:call-template name="form:radio">
		<xsl:with-param name="event" select="$event"/>
		<xsl:with-param name="handle" select="$handle"/>
		<xsl:with-param name="section" select="$section"/>
		<xsl:with-param name="value">
			<xsl:choose>
				<xsl:when test="$allow-multiple='yes'">
					<xsl:value-of select="$allow-multiple-value"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$checked"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:with-param>
		<xsl:with-param name="existing-value">
			<xsl:if test="$allow-multiple='yes'">
				<xsl:value-of select="$checked"/>
			</xsl:if>
		</xsl:with-param>
		<xsl:with-param name="checked-by-default" select="$checked-by-default"/>
		<xsl:with-param name="class" select="$class"/>
		<xsl:with-param name="title" select="$title"/>
		<xsl:with-param name="type" select="'checkbox'"/>
		<xsl:with-param name="allow-multiple" select="$allow-multiple"/>
	</xsl:call-template>
	
</xsl:template>

<!--
Name: form:radio
Description: Renders an HTML radio `input` element
Returns: HTML <input> element
Parameters:
* `handle` (mandatory, string): Handle of the field name
* `value` (optional, string): The selected value for this radio sent when the form is submitted
* `existing-value` (optional, string): An initial value. Selects radio if it matches $value
* `checked-by-default` (optional, string): When there is no initial $existing-value (a fresh form), select by default ("yes", "no"). Defaults to "no"
* `class` (optional, string): Class attribute value
* `title` (optional, string): Title attribute value
* `type` (optional, string): Internal use only ("radio", "checkbox"). Defaults to "radio"
* `section` (optional, string): Use with EventEx to change "fields[...]" to a section handle
* `event` (optional, XPath): XPath expression to the specific event within the page <events> node
* `allow-multiple` (optional, string): Internal use only ("yes", "no"). Whether control is part of a radio/checkbox list. Defaults to "no"
-->
<xsl:template name="form:radio">
	<xsl:param name="handle"/>
	<xsl:param name="value"/>
	<xsl:param name="existing-value"/>
	<xsl:param name="checked-by-default" select="'no'"/>
	<xsl:param name="class"/>
	<xsl:param name="title"/>
	<xsl:param name="event" select="$form:event"/>
	<xsl:param name="section" select="'fields'"/>
	<xsl:param name="type" select="'radio'"/>
	<xsl:param name="allow-multiple" select="'no'"/>
	
	<xsl:variable name="value" select="normalize-space($value)"/>
	<xsl:variable name="selected-value" select="normalize-space($existing-value)"/>
	
	<xsl:variable name="postback-value">
		<xsl:call-template name="form:postback-value">
			<xsl:with-param name="event" select="$event"/>
			<xsl:with-param name="handle" select="$handle"/>
			<xsl:with-param name="section" select="$section"/>
		</xsl:call-template>
	</xsl:variable>
	
	<xsl:element name="input" use-attribute-sets="form:attributes-general">
	
		<xsl:attribute name="type"><xsl:value-of select="$type"/></xsl:attribute>
		
		<xsl:if test="$allow-multiple='yes'">
			<xsl:attribute name="name">
				<xsl:call-template name="form:control-name">
					<xsl:with-param name="handle" select="$handle"/>
					<xsl:with-param name="section" select="$section"/>
				</xsl:call-template>
				<xsl:text>[]</xsl:text>
			</xsl:attribute>
		</xsl:if>
		
		<xsl:attribute name="value">
			<xsl:choose>
				<xsl:when test="$type='checkbox' and $allow-multiple='no'">
					<xsl:text>yes</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$value"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:attribute>
		
		<xsl:choose>
			<xsl:when test="$type='radio'">
				<xsl:choose>
					<xsl:when test="$value=$postback-value">
						<xsl:attribute name="checked">checked</xsl:attribute>
					</xsl:when>
					<xsl:when test="$postback-value='' and $value=$selected-value">
						<xsl:attribute name="checked">checked</xsl:attribute>
					</xsl:when>
					<xsl:when test="$postback-value='' and $selected-value='' and $checked-by-default='yes'">
						<xsl:attribute name="checked">checked</xsl:attribute>
					</xsl:when>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$type='checkbox'">
				<xsl:choose>
					<!-- checked from the event -->
					<xsl:when test="$postback-value='Yes' or $postback-value='yes'">
						<xsl:attribute name="checked">checked</xsl:attribute>
					</xsl:when>
					<!-- checked from an initial value -->
					<xsl:when test="$postback-value='' and ($value='Yes' or $value='yes')">
						<xsl:attribute name="checked">checked</xsl:attribute>
					</xsl:when>
					<!-- if no event and no initial value, see it checked by default -->
					<xsl:when test="$postback-value='' and $value='' and $checked-by-default='yes'">
						<xsl:attribute name="checked">checked</xsl:attribute>
					</xsl:when>
					<!-- when allowing multiple, check if this value exists -->
					<xsl:when test="$allow-multiple='yes' and $selected-value='yes'">
						<xsl:attribute name="checked">checked</xsl:attribute>
					</xsl:when>					
				</xsl:choose>
			</xsl:when>
		</xsl:choose>
		  
	</xsl:element>
	
</xsl:template>

<!--
Name: form:input
Description: Renders an HTML text `input` element with support for `password` and `file` types
Returns: HTML <input> element
Parameters:
* `handle` (mandatory, string): Handle of the field name
* `value` (optional, string): Initial value of form control. Will not work for `file` inputs.
* `type` (optional, string): Type attribute value ("text", "password" "file", "hidden"). For "checkbox" and "radio" types see form:checkbox and form:radio templates. Defaults to "text"
* `class` (optional, string): Class attribute value
* `title` (optional, string): Title attribute value
* `size` (optional, string): Size attribute value
* `maxlength` (optional, string): Maxlength attribute value
* `autocomplete` (optional, string): Autocomplete attribute value ("off"). Not set by default
* `section` (optional, string): Use with EventEx to change "fields[...]" to a section handle
* `event` (optional, XPath): XPath expression to the specific event within the page <events> node
-->
<xsl:template name="form:input">
	<xsl:param name="handle"/>
	<xsl:param name="value"/>
	<xsl:param name="class"/>
	<xsl:param name="title"/>
	<xsl:param name="type" select="'text'"/>
	<xsl:param name="size"/>
	<xsl:param name="maxlength"/>
	<xsl:param name="autocomplete"/>
	<xsl:param name="section" select="'fields'"/>
	<xsl:param name="event" select="$form:event"/>
	
	<xsl:variable name="initial-value" select="normalize-space($value)"/>

	<xsl:variable name="postback-value">
		<xsl:call-template name="form:postback-value">
			<xsl:with-param name="event" select="$event"/>
			<xsl:with-param name="handle" select="$handle"/>
			<xsl:with-param name="section" select="$section"/>
		</xsl:call-template>
	</xsl:variable>
	
	<xsl:element name="input" use-attribute-sets="form:attributes-general">
		
		<xsl:attribute name="type"><xsl:value-of select="$type"/></xsl:attribute>
		
		<xsl:if test="$size">
			<xsl:attribute name="size"><xsl:value-of select="$size"/></xsl:attribute>
		</xsl:if>
		
		<xsl:if test="$maxlength">
			<xsl:attribute name="maxlength"><xsl:value-of select="$maxlength"/></xsl:attribute>
		</xsl:if>
		
		<xsl:if test="$autocomplete='off'">
			<xsl:attribute name="autocomplete"><xsl:value-of select="$autocomplete"/></xsl:attribute>
		</xsl:if>
		
		<xsl:attribute name="value">
			<xsl:choose>
				<xsl:when test="$event and ($initial-value != $postback-value)">
					<xsl:value-of select="$postback-value"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$initial-value"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:attribute>
	
	</xsl:element>
	
</xsl:template>

<!--
Name: form:textarea
Description: Renders an HTML `textarea` element
Returns: HTML <textarea> element
Parameters:
* `handle` (mandatory, string): Handle of the field name
* `value` (optional, string): Contents of the textarea
* `class` (optional, string): Class attribute value
* `rows` (optional, string): Rows attribute value
* `cols` (optional, string): cols attribute value
* `section` (optional, string): Use with EventEx to change "fields[...]" to a section handle
* `event` (optional, XPath): XPath expression to the specific event within the page <events> node
-->
<xsl:template name="form:textarea">
	<xsl:param name="handle"/>
	<xsl:param name="value"/>
	<xsl:param name="class"/>
	<xsl:param name="title"/>
	<xsl:param name="rows"/>
	<xsl:param name="cols"/>
	<xsl:param name="section" select="'fields'"/>
	<xsl:param name="event" select="$form:event"/>
	
	<xsl:variable name="initial-value" select="$value"/>
	<xsl:variable name="initial-value-normalized" select="normalize-space($value)"/>
	
	<xsl:variable name="postback-value">
		<xsl:call-template name="form:postback-value">
			<xsl:with-param name="event" select="$event"/>
			<xsl:with-param name="handle" select="$handle"/>
			<xsl:with-param name="section" select="$section"/>
			<xsl:with-param name="normalize" select="'no'"/>
		</xsl:call-template>
	</xsl:variable>
	
	<xsl:variable name="postback-value-normalized">
		<xsl:call-template name="form:postback-value">
			<xsl:with-param name="event" select="$event"/>
			<xsl:with-param name="handle" select="$handle"/>
			<xsl:with-param name="section" select="$section"/>
		</xsl:call-template>
	</xsl:variable>
	
	<xsl:element name="textarea" use-attribute-sets="form:attributes-general">
		
		<xsl:if test="$rows">
			<xsl:attribute name="rows"><xsl:value-of select="$rows"/></xsl:attribute>
		</xsl:if>
		
		<xsl:if test="$cols">
			<xsl:attribute name="cols"><xsl:value-of select="$cols"/></xsl:attribute>
		</xsl:if>
		
		<xsl:choose>
			<xsl:when test="$event and ($initial-value-normalized != $postback-value-normalized)">
				<xsl:value-of select="$postback-value"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$initial-value"/>
			</xsl:otherwise>
		</xsl:choose>
		
	</xsl:element>
	
</xsl:template>

<!--
Name: form:select
Description: Renders an HTML `select` element
Returns: HTML <select> element
Parameters:
* `handle` (mandatory, string): Handle of the field name
* `options` (mandatory, XPath/XML): Options to build a list of <option> elements. Has presets! See examples.
* `value` (optional, string/XML): Initial selected value
* `class` (optional, string): Class attribute value
* `title` (optional, string): Title attribute value
* `allow-multiple` (optional, string): Allow selection of multiple options ("yes", "no"). Defaults to "no"
* `section` (optional, string): Use with EventEx to change "fields[...]" to a section handle
* `event` (optional, XPath): XPath expression to the specific event within the page <events> node
-->
<xsl:template name="form:select">
	<xsl:param name="handle"/>	
	<xsl:param name="value"/>
	<xsl:param name="class"/>
	<xsl:param name="title"/>
	<xsl:param name="options"/>
	<xsl:param name="allow-multiple"/>
	<xsl:param name="section" select="'fields'"/>
	<xsl:param name="event" select="$form:event"/>

	<xsl:variable name="initial-value">
		<xsl:choose>
			<xsl:when test="exsl:node-set($value)/*">
				<xsl:copy-of select="$value"/>
			</xsl:when>
			<xsl:otherwise>
				<value><xsl:value-of select="normalize-space($value)"/></value>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	
	<xsl:variable name="postback-value">
		<xsl:call-template name="form:postback-value">
			<xsl:with-param name="event" select="$event"/>
			<xsl:with-param name="handle" select="$handle"/>
			<xsl:with-param name="section" select="$section"/>
		</xsl:call-template>
	</xsl:variable>
	
	<xsl:element name="select" use-attribute-sets="form:attributes-general">
		
		<xsl:if test="$allow-multiple='yes'">
			<xsl:attribute name="multiple">multiple</xsl:attribute>
			<xsl:variable name="name">
				<xsl:call-template name="form:control-name">
					<xsl:with-param name="handle" select="$handle"/>
					<xsl:with-param name="section" select="$section"/>
				</xsl:call-template>
				<xsl:text>[]</xsl:text>
			</xsl:variable>
			<xsl:attribute name="name"><xsl:value-of select="$name"/></xsl:attribute>
		</xsl:if>
		
		<xsl:variable name="options">
			<xsl:choose>
				
				<xsl:when test="starts-with(string($options),'days')">
					<xsl:if test="not(contains(string($options),'no-label'))">
						<option value="">Day</option>
					</xsl:if>
					<xsl:call-template name="form:incrementor">
						<xsl:with-param name="start" select="'1'"/>
						<xsl:with-param name="iterations" select="31"/>
					</xsl:call-template>
				</xsl:when>
				
				<xsl:when test="starts-with(string($options),'months')">
					<xsl:if test="not(contains(string($options),'no-label'))">
						<option value="">Month</option>
					</xsl:if>
					<option value="01">January</option>
					<option value="02">February</option>
					<option value="03">March</option>
					<option value="04">April</option>
					<option value="05">May</option>
					<option value="06">June</option>
					<option value="07">July</option>
					<option value="08">August</option>
					<option value="09">September</option>
					<option value="10">October</option>
					<option value="11">November</option>
					<option value="12">December</option>
				</xsl:when>
				
				<xsl:when test="contains(string($options),'years')">
					<xsl:if test="not(contains(string($options),'no-label'))">
						<option value="">Year</option>
					</xsl:if>
					<xsl:choose>
						<xsl:when test="contains(string($options),'years-')">
							<xsl:call-template name="form:incrementor">
								<xsl:with-param name="start" select="$this-year"/>
								<xsl:with-param name="iterations" select="number(substring-after($options,'-') + 1)"/>
								<xsl:with-param name="direction" select="'-'"/>
							</xsl:call-template>
						</xsl:when>
						<xsl:when test="contains(string($options),'years+')">
							<xsl:call-template name="form:incrementor">
								<xsl:with-param name="start" select="$this-year"/>
								<xsl:with-param name="iterations" select="number(substring-after($options,'+') + 1)"/>
							</xsl:call-template>
						</xsl:when>
					</xsl:choose>
				</xsl:when>
				
				<xsl:otherwise>
					<xsl:for-each select="exsl:node-set($options)/* | exsl:node-set($options)">
						<xsl:if test="text()!=''">
							<option>
								<xsl:if test="@handle or @id or @link-id or @link-handle or @value">
									<xsl:attribute name="value">
										<xsl:value-of select="@handle | @id | @link-id | @link-handle | @value"/>
									</xsl:attribute>
								</xsl:if>
								<xsl:value-of select="text()"/>
							</option>
						</xsl:if>						
					</xsl:for-each>
				</xsl:otherwise>
				
			</xsl:choose>
		</xsl:variable>
	
		<xsl:for-each select="exsl:node-set($options)/option">
			
			<xsl:variable name="option-value">
				<xsl:choose>
					<xsl:when test="@value">
						<xsl:value-of select="@value"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="text()"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
		
			<option>
				<xsl:if test="@value">
					<xsl:attribute name="value"><xsl:value-of select="@value"/></xsl:attribute>
				</xsl:if>
				
				<xsl:if test="
					($event and (
						$option-value = $postback-value or 
						exsl:node-set($postback-value)//*[text()=$option-value] or
						exsl:node-set($postback-value)//*[@id=$option-value]
					)) or 
					(not($event) and (
						$option-value = $initial-value or 
						exsl:node-set($initial-value)//*[text()=$option-value] or
						exsl:node-set($initial-value)//*[@id=$option-value]
					))
					">
					<xsl:attribute name="selected">selected</xsl:attribute>
				</xsl:if>
				
				<xsl:value-of select="text()"/>
			</option>
			
		</xsl:for-each>
		
  </xsl:element>

</xsl:template>

<!--
Name: form:radiobutton-list
Description: Renders a collection of HTML radio `input` elements wrapped with `label` elements
Returns: HTML <select> element
Parameters:
* `handle` (mandatory, string): Handle of the field name
* `options` (mandatory, XPath/XML): Options to build a list of <option> elements. Has presets! See examples.
* `value` (optional, string): Initial selected value
* `class` (optional, string): Class attribute value
* `title` (optional, string): Title attribute value
* `section` (optional, string): Use with EventEx to change "fields[...]" to a section handle
* `event` (optional, XPath): XPath expression to the specific event within the page <events> node
-->
<xsl:template name="form:radiobutton-list">
	<xsl:param name="handle"/>
	<xsl:param name="value"/>
	<xsl:param name="class"/>
	<xsl:param name="title"/>
	<xsl:param name="options"/>
	<xsl:param name="section" select="'fields'"/>
	<xsl:param name="event" select="$form:event"/>
	
	<xsl:variable name="select">
		<xsl:call-template name="form:select">
			<xsl:with-param name="event" select="$event"/>
			<xsl:with-param name="handle" select="$handle"/>
			<xsl:with-param name="section" select="$section"/>
			<xsl:with-param name="value" select="$value"/>
			<xsl:with-param name="class" select="$class"/>
			<xsl:with-param name="title" select="$title"/>
			<xsl:with-param name="options" select="$options"/>
		</xsl:call-template>
	</xsl:variable>
		
	<xsl:for-each select="exsl:node-set($select)//option">
		
		<xsl:call-template name="form:label">
			<xsl:with-param name="event" select="$event"/>
			<xsl:with-param name="handle" select="$handle"/>
			<xsl:with-param name="section" select="$section"/>
			<xsl:with-param name="text" select="."/>
			<xsl:with-param name="child-position" select="'before'"/>
			<xsl:with-param name="child">
				<xsl:call-template name="form:radio">
					<xsl:with-param name="event" select="$event"/>
					<xsl:with-param name="handle" select="$handle"/>
					<xsl:with-param name="section" select="$section"/>
					<xsl:with-param name="value">
						<xsl:choose>
							<xsl:when test="@value"><xsl:value-of select="@value"/></xsl:when>
							<xsl:otherwise><xsl:value-of select="."/></xsl:otherwise>
						</xsl:choose>
					</xsl:with-param>
					<xsl:with-param name="existing-value">
						<xsl:if test="@selected">
							<xsl:choose>
								<xsl:when test="@value"><xsl:value-of select="@value"/></xsl:when>
								<xsl:otherwise><xsl:value-of select="."/></xsl:otherwise>
							</xsl:choose>
						</xsl:if>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:with-param>
		</xsl:call-template>
		
	</xsl:for-each>
	
</xsl:template>

<!--
Name: form:checkbox-list
Description: Renders a collection of HTML checkbox `input` elements wrapped with `label` elements
Returns: HTML <select> element
Parameters:
* `handle` (mandatory, string): Handle of the field name
* `options` (mandatory, XPath/XML): Options to build a list of <option> elements. Has presets! See examples.
* `value` (optional, string/XML): Initial selected value
* `class` (optional, string): Class attribute value
* `title` (optional, string): Title attribute value
* `section` (optional, string): Use with EventEx to change "fields[...]" to a section handle
* `event` (optional, XPath): XPath expression to the specific event within the page <events> node
-->
<xsl:template name="form:checkbox-list">
	<xsl:param name="handle"/>	
	<xsl:param name="value"/>
	<xsl:param name="class"/>
	<xsl:param name="title"/>
	<xsl:param name="options"/>
	<xsl:param name="section" select="'fields'"/>
	<xsl:param name="event" select="$form:event"/>
	
	<xsl:variable name="select">
		<xsl:call-template name="form:select">
			<xsl:with-param name="event" select="$event"/>
			<xsl:with-param name="handle" select="$handle"/>
			<xsl:with-param name="section" select="$section"/>
			<xsl:with-param name="value" select="$value"/>
			<xsl:with-param name="class" select="$class"/>
			<xsl:with-param name="title" select="$title"/>
			<xsl:with-param name="options" select="$options"/>
			<xsl:with-param name="allow-multiple" select="'yes'"/>
		</xsl:call-template>
	</xsl:variable>
	
	<xsl:for-each select="exsl:node-set($select)//option">
		
		<xsl:call-template name="form:label">
			<xsl:with-param name="event" select="$event"/>
			<xsl:with-param name="handle" select="$handle"/>
			<xsl:with-param name="section" select="$section"/>
			<xsl:with-param name="text" select="."/>
			<xsl:with-param name="child-position" select="'before'"/>
			<xsl:with-param name="child">
				<xsl:call-template name="form:checkbox">
					<xsl:with-param name="event" select="$event"/>
					<xsl:with-param name="handle" select="$handle"/>
					<xsl:with-param name="section" select="$section"/>
					<xsl:with-param name="allow-multiple" select="'yes'"/>
					<xsl:with-param name="allow-multiple-value">
						<xsl:choose>
							<xsl:when test="@value"><xsl:value-of select="@value"/></xsl:when>
							<xsl:otherwise><xsl:value-of select="."/></xsl:otherwise>
						</xsl:choose>
					</xsl:with-param>
					<xsl:with-param name="checked">
						<xsl:if test="@selected">yes</xsl:if>
					</xsl:with-param>
					<xsl:with-param name="existing-value">
						<xsl:choose>
							<xsl:when test="@value"><xsl:value-of select="@value"/></xsl:when>
							<xsl:otherwise><xsl:value-of select="."/></xsl:otherwise>
						</xsl:choose>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:with-param>
		</xsl:call-template>
		
	</xsl:for-each>
	
</xsl:template>

<!-- Attributes common to all form controls (name, id, title) -->
<xsl:attribute-set name="form:attributes-general" use-attribute-sets="form:attribute-class">
	
	<xsl:attribute name="name">
		<xsl:call-template name="form:control-name">
			<xsl:with-param name="handle" select="$handle"/>
			<xsl:with-param name="section" select="$section"/>
		</xsl:call-template>
	</xsl:attribute>
	
	<xsl:attribute name="id">
		<xsl:call-template name="form:control-id">
			<xsl:with-param name="name">
				<xsl:call-template name="form:control-name">
					<xsl:with-param name="handle" select="$handle"/>
					<xsl:with-param name="section" select="$section"/>
				</xsl:call-template>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:attribute>
	
	<xsl:attribute name="title">
		<xsl:value-of select="$title"/>
	</xsl:attribute>
	
</xsl:attribute-set>

<!-- Class attribute separate so it can be applied independently (for label elements) -->
<xsl:attribute-set name="form:attribute-class">
	
	<xsl:attribute name="class">
		
		<xsl:variable name="valid">
			<xsl:call-template name="form:control-is-valid">
				<xsl:with-param name="event" select="$event"/>
				<xsl:with-param name="handle" select="$handle"/>
				<xsl:with-param name="section" select="$section"/>
			</xsl:call-template>
		</xsl:variable>
		
		<xsl:if test="$class or $valid='false'">
			<xsl:value-of select="$class"/>
			<xsl:if test="$valid='false'">
				<xsl:if test="$class!=''">
					<xsl:text> </xsl:text>
				</xsl:if>
				<xsl:value-of select="$form:invalid-class"/>
			</xsl:if>
		</xsl:if>
		
	</xsl:attribute>
	
</xsl:attribute-set>

<!--
Name: form:control-is-valid
Description: returns whether a field is valid or not
Returns: boolean (string "true|false")
-->
<xsl:template name="form:control-is-valid">
	<xsl:param name="handle"/>
	<xsl:param name="section"/>
	<xsl:param name="event" select="$form:event"/>
	
	<xsl:variable name="index-key">
		<xsl:call-template name="form:section-index-key">
			<xsl:with-param name="section" select="$section"/>
		</xsl:call-template>
	</xsl:variable>
	
	<xsl:variable name="section-handle">
		<xsl:call-template name="form:section-handle">
			<xsl:with-param name="section" select="$section"/>
		</xsl:call-template>
	</xsl:variable>
	
	<xsl:choose>
		<xsl:when test="$section!='fields' and $index-key!=''">
			<xsl:choose>
				<xsl:when test="$event//entry[@section-handle=$section-handle and @index-key=$index-key]/*[name()=$handle and (@type='missing' or @type='invalid')]">false</xsl:when>
				<xsl:otherwise>true</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<xsl:when test="$section!='fields'">
			<xsl:choose>
				<xsl:when test="$event//entry[@section-handle=$section-handle]/*[name()=$handle and (@type='missing' or @type='invalid')]">false</xsl:when>
				<xsl:otherwise>true</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<xsl:otherwise>
			<xsl:choose>
				<xsl:when test="$event/*[name()=$handle and (@type='missing' or @type='invalid')]">false</xsl:when>
				<xsl:otherwise>true</xsl:otherwise>
			</xsl:choose>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!--
Name: form:control-name
Description: returns a keyed field name for use in HTML @name attributes
Returns: string
-->
<xsl:template name="form:control-name">
	<xsl:param name="handle"/>
	<xsl:param name="section"/>
	
	<!--xsl:variable name="section">
		<xsl:choose>
			<xsl:when test="$section=''">
				<xsl:text>fields</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$section"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable-->
	
	<xsl:value-of select="concat($section,'[',$handle,']')"/>
</xsl:template>

<!--
Name: form:control-id
Description: returns a sanitised version of a field's @name for use as a unique @id attribute
Returns: string
-->
<xsl:template name="form:control-id">
	<xsl:param name="name"/>
		
	<xsl:value-of select="translate(translate($name,'[','-'),']','')"/>
</xsl:template>

<!--
Name: form:postback-value
Description: determines the postback value of a control if an Event has been triggered
Returns: string
-->
<xsl:template name="form:postback-value">
	<xsl:param name="handle"/>
	<xsl:param name="section"/>
	<xsl:param name="normalize" select="'yes'"/>
	<xsl:param name="event" select="$form:event"/>
	
	<xsl:variable name="index-key">
		<xsl:call-template name="form:section-index-key">
			<xsl:with-param name="section" select="$section"/>
		</xsl:call-template>
	</xsl:variable>
	
	<xsl:variable name="section-handle">
		<xsl:call-template name="form:section-handle">
			<xsl:with-param name="section" select="$section"/>
		</xsl:call-template>
	</xsl:variable>
	
	<xsl:choose>
		<xsl:when test="$section!='fields' and $index-key!=''">
			<xsl:choose>
				<xsl:when test="$event/entry[@section-handle=$section-handle and @index-key=$index-key]/post-values/*[name()=$handle]/*">
					<xsl:copy-of select="$event/entry[@section-handle=$section-handle and @index-key=$index-key]/post-values/*[name()=$handle]/*"/>
				</xsl:when>
				<xsl:when test="$normalize='yes'">
					<xsl:value-of select="normalize-space($event/entry[@section-handle=$section-handle and @index-key=$index-key]/post-values/*[name()=$handle])"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$event/entry[@section-handle=$section-handle and @index-key=$index-key]/post-values/*[name()=$handle]"/>
				</xsl:otherwise>
			</xsl:choose>			
		</xsl:when>
		<xsl:when test="$section!='fields'">
			<xsl:choose>
				<xsl:when test="$event/entry[@section-handle=$section-handle]/post-values/*[name()=$handle]/*">
					<xsl:copy-of select="$event/entry[@section-handle=$section-handle]/post-values/*[name()=$handle]/*"/>
				</xsl:when>
				<xsl:when test="$normalize='yes'">
					<xsl:value-of select="normalize-space($event/entry[@section-handle=$section-handle]/post-values/*[name()=$handle])"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$event/entry[@section-handle=$section-handle]/post-values/*[name()=$handle]"/>
				</xsl:otherwise>
			</xsl:choose>			
		</xsl:when>
		<xsl:otherwise>
			<xsl:for-each select="$event/post-values/*[name()=$handle]">
				<xsl:choose>
					<xsl:when test="./*">
						<xsl:copy-of select="."/>
					</xsl:when>
					<xsl:when test="$normalize='yes'">
						<value><xsl:value-of select="normalize-space(.)"/></value>
					</xsl:when>
					<xsl:otherwise>
						<value><xsl:value-of select="."/></value>
					</xsl:otherwise>
				</xsl:choose>				
			</xsl:for-each>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!--
Name: form:section-handle
Description: increases or decreases a number between two bounds
Returns: a nodeset of <option> elements
-->
<xsl:template name="form:section-handle">
	<xsl:param name="section"/>
		
	<xsl:choose>
		<xsl:when test="contains($section,'[')">
			<xsl:value-of select="substring-before($section,'[')"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="$section"/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!--
Name: form:section-index-key
Description: returns the index from a section handle
Returns: string
-->
<xsl:template name="form:section-index-key">
	<xsl:param name="section"/>
	
	<xsl:if test="contains($section,'[')">
		<xsl:value-of select="substring-after(substring-before($section,']'),'[')"/>
	</xsl:if>
</xsl:template>

<!--
Name: form:incrementor
Description: increases or decreases a number between two bounds
Returns: a nodeset of <option> elements
-->
<xsl:template name="form:incrementor">
	<xsl:param name="start" select="$start"/>
	<xsl:param name="iterations" select="$iterations"/>
	<xsl:param name="count" select="$iterations"/>
	<xsl:param name="direction" select="'+'"/>
	<xsl:if test="$count > 0">
		<option>
			<xsl:choose>
				<xsl:when test="$direction='-'">
					<xsl:value-of select="$start - ($iterations - $count)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$start + ($iterations - $count)"/>
				</xsl:otherwise>
			</xsl:choose>
		</option>
		<xsl:call-template name="form:incrementor">
			<xsl:with-param name="count" select="$count - 1"/>
			<xsl:with-param name="start" select="$start"/>
			<xsl:with-param name="iterations" select="$iterations"/>
			<xsl:with-param name="direction" select="$direction"/>
		</xsl:call-template>
	</xsl:if>  
</xsl:template>

<!--
Name: form:replace-template, matches element nodes
Description: traverse a block of XML and replace placeholder with text string
Returns: XML
-->
<xsl:template match="*" mode="form:replace-template">
	<xsl:param name="replacement"/>
	<xsl:element name="{name()}">
		<xsl:apply-templates select="* | @* | text()" mode="form:replace-template">
			<xsl:with-param name="replacement" select="$replacement"/>
		</xsl:apply-templates>
	</xsl:element>
</xsl:template>

<!--
Name: form:replace-template, matches attribute node
Description: traverse a block of XML and replace placeholder with text string
Returns: XML
-->
<xsl:template match="@*" mode="form:replace-template">
	<xsl:param name="replacement"/>
	<xsl:attribute name="{name(.)}">
		<xsl:value-of select="."/>
	</xsl:attribute>
</xsl:template>

<!--
Name: form:replace-template, matches text nodes
Description: traverse a block of XML and replace placeholder with text string
Returns: XML
-->
<xsl:template match="text()" mode="form:replace-template">
	<xsl:param name="replacement"/>
	<xsl:choose>
		<xsl:when test="string(normalize-space(.))='$'">
			<xsl:value-of select="normalize-space($replacement)"/>
			<xsl:if test="string-length(.) &gt; 1">
				<xsl:text> </xsl:text>
			</xsl:if>
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="string(.)"/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

</xsl:stylesheet>