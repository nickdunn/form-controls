<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
	version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:exsl="http://exslt.org/common"
	xmlns:form="http://nick-dunn.co.uk/xslt/form-controls"
	extension-element-prefixes="exsl form">

<!--
Name: Form Controls
Description: A suite of templates to build robust form control elements attached to Symphony events
Version: 0.3
Author: Nick Dunn <nick@nick-dunn.co.uk>
URL: http://symphony21.com/downloads/xslt/file/.../

Todo:
* add support for optgroups in selects
-->

<!-- Class valid added to invalid form controls -->
<xsl:variable name="form:invalid-class" select="'invalid'"/>

<!--
Name: validation-summary
Description: provides a summary of validation errors from an event
Returns: HTML
Parameters:
* event (mandatory, XPath) XPath expression to the specific event within the page <events> node
* header (optional, string) custom error message at the top of the summary. Defaults to Symphony's default event message

* section (optional, string) only show validation errors for a named section. With or without an index-key e.g.
	'blog-articles' or 'comments[2]'
	
* errors (optional, string) list of nodes providing custom error messages to override specific field messages e.g.
	
	<error field="title">Please enter a title</error>
	any error on the title field (missing or invalid)
	
	<error field="title" type="missing,invalid">Please enter a title</error>
	any error on the title field (missing or invalid)
	
	<error field="email" type="missing">Please enter an e-mail address</error>
	when email is missing
	
	<error field="email" type="invalid">Please enter a valid e-mail address</error> 
	when email is invalid
	
-->
<xsl:template name="form:validation-summary">
	<xsl:param name="event" select="$form:event"/>
	<xsl:param name="section" select="'fields'"/>
	<xsl:param name="header" select="$event/message"/>
	<xsl:param name="success" select="$event/message"/>
	<xsl:param name="errors"/>
	
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

				<p><xsl:value-of select="$header"/></p>

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

									<!-- missing and a section specified -->
									<xsl:when test="@type='missing' and exsl:node-set($errors)/error[@handle=name(current()) and contains(@type,'missing') and @section = current()/parent::entry/@section-handle]">
										<xsl:value-of select="exsl:node-set($errors)/error[@handle=name(current()) and contains(@type,'missing') and @section = current()/parent::entry/@section-handle]"/>
									</xsl:when>
									<!-- missing -->
									<xsl:when test="@type='missing' and exsl:node-set($errors)/error[@handle=name(current()) and contains(@type,'missing')]">
										<xsl:value-of select="exsl:node-set($errors)/error[@handle=name(current()) and contains(@type,'missing')]"/>
									</xsl:when>

									<!-- invalid and a section specified-->
									<xsl:when test="@type='invalid' and exsl:node-set($errors)/error[handle=name(current()) and contains(@type,'invalid') and @section = current()/parent::entry/@section-handle]">
										<xsl:value-of select="exsl:node-set($errors)/error[@handle=name(current()) and contains(@type,'invalid') and @section = current()/parent::entry/@section-handle]"/>
									</xsl:when>
									<!-- invalid -->
									<xsl:when test="@type='invalid' and exsl:node-set($errors)/error[handle=name(current()) and contains(@type,'invalid')]">
										<xsl:value-of select="exsl:node-set($errors)/error[@handle=name(current()) and contains(@type,'invalid')]"/>
									</xsl:when>

									<!-- no specific type match, section specified -->
									<xsl:when test="exsl:node-set($errors)/error[@handle=name(current()) and not(@type) and @section = current()/parent::entry/@section-handle]">
										<xsl:value-of select="exsl:node-set($errors)/error[@handle=name(current()) and @section = current()/parent::entry/@section-handle]"/>
									</xsl:when>
									<!-- no specific type match -->
									<xsl:when test="exsl:node-set($errors)/error[@handle=name(current()) and not(@type)]">
										<xsl:value-of select="exsl:node-set($errors)/error[@handle=name(current())]"/>
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
				<p><xsl:value-of select="$success"/></p>
			</div>
			
		</xsl:when>
	</xsl:choose>

</xsl:template>

<!--
Name: label
Description: builds an HTML label element
Returns: HTML <label> element
Parameters:
* event (mandatory, XPath) XPath expression to the specific event within the page <events> node
* for (mandatory, string) handle of a Symphony field name that this label is associated with
* text (optional, string) text value of the label. Defaults to field name ($for value)
* section (optional, string) custom key section
* child (XML, string) places this XML inside the label, for wrapping elements with the label
* child-position (optional, string) place the child before or after the label text. Defaults to "after"
* class (optional, string) value of the HTML @class attribute
-->
<xsl:template name="form:label">
	<xsl:param name="for"/>
	<xsl:param name="text"/>
	<xsl:param name="child"/>
	<xsl:param name="child-position" select="'after'"/>
	<xsl:param name="class"/>
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
		
		<xsl:if test="$child and $child-position='after'">
			<xsl:copy-of select="$child"/>
		</xsl:if>
		
	</xsl:element>
	
</xsl:template>

<!--
Name: checkbox
Description: builds an HTML checkbox element
Returns: HTML <input> element
Parameters:
* event (mandatory, XPath) XPath expression to the specific event within the page <events> node
* handle (mandatory, string) handle of a Symphony field name
* section (optional, string) custom key section
* checked (optional, string) existing value to pre-check the checkbox ("yes|no")
* checked-by-default (optional, string) when no existing $checked value, should this checkbox be selected? Defaults to "no"
* class (optional, string) value of the HTML @class attribute
* title	(optional, string) value of the HTML @title attribute
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
Name: radio
Description: builds an HTML radio element
Returns: HTML <input> element
Parameters:
* event (mandatory, XPath) XPath expression to the specific event within the page <events> node
* handle (mandatory, string) handle of a Symphony field name
* section (optional, string) custom key section
* value	(optional, string) the selected value of this radio button
* existing-value (optional, string) existing value to pre-check a radio button
* checked-by-default (optional, string) when no $existing-value, should this radio button be selected? Defaults to "no"
* class (optional, string) value of the HTML @class attribute
* title (optional, string) value of the HTML @title attribute
* type (optional, string) internal use ("radio|checkbox"). Defaults to "radio"
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
Name: input
Description: builds an HTML input element
Returns: HTML <input> element
Parameters:
* event (mandatory, XPath) XPath expression to the specific event within the page <events> node
* handle (mandatory, string) handle of a Symphony field name
* section (optional, string) custom key section
* value (optional, string) value of the HTML @value attribute
* class (optional, string) value of the HTML @class attribute
* title (optional, string) value of the HTML @title attribute
* type (optional, string) value of the HTML @type attribute. Defaults to "text". Alternatives could be "file" and "password"
* size (optional, string) value of the HTML @size attribute
* maxlength (optional, string) value of the HTML @maxlength attribute
* autocomplete (optional, string) value of the HTML @autocomplete attribute (e.g. "off")
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
Name: textarea
Description: builds an HTML textarea element
Returns: HTML <textarea> element
Parameters:
* event (mandatory, XPath) XPath expression to the specific event within the page <events> node
* handle (mandatory, string) handle of a Symphony field name
* section (optional, string) custom key section
* value (optional, string) value of the HTML @value attribute
* class (optional, string) value of the HTML @class attribute
* title (optional, string) value of the HTML @title attribute
* rows (optional, string) value of the HTML @rows attribute
* cols (optional, string) value of the HTML @cols attribute	
-->
<xsl:template name="form:textarea">
	<xsl:param name="handle"/>
	<xsl:param name="value"/>
	<xsl:param name="class"/>
	<xsl:param name="title"/>
	<xsl:param name="rows"/>
	<xsl:param name="cols"/>
	<xsl:param name="event" select="$form:event"/>
	<xsl:param name="section" select="'fields'"/>
	
	<xsl:variable name="initial-value" select="normalize-space($value)"/>
	
	<xsl:variable name="postback-value">
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
			<xsl:when test="$event and ($initial-value != $postback-value)">
				<xsl:value-of select="$postback-value"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$initial-value"/>
			</xsl:otherwise>
		</xsl:choose>
		
	</xsl:element>
	
</xsl:template>

<!--
Name: select
Description: builds an HTML select element
Returns: HTML <select> element
Parameters:
* event (mandatory, XPath) XPath expression to the specific event within the page <events> node
* handle (mandatory, string) handle of a Symphony field name
* section (optional, string) custom key section
* value (optional, string) value of the HTML @value attribute
* class (optional, string) value of the HTML @class attribute
* title (optional, string) value of the HTML @title attribute
* options (mandatory, string/Xpath/XML) options to build a list of <option> elements. Has presets! e.g.
	
	String:	'days'
			returns a list of 31 days, for building a series of date selects
			e.g. <option>1</option> ... <option>31</option>
		
	String:	'months'
			returns a list of 12 months
			e.g. <option value="01">January</option> ... <option value="12">December</option>
		
	String:	'years+10' ('years+N')
			returns a list of years between this year and 10 years from now
			e.g. <option>2009</option> ... <option>2019</option>
	
	String:	'years-3' ('years-N')
			returns a list of years between this year and 3 years in the past
			e.g. <option>2009</option> ... <option>2006</option>
	
	In addition to present strings, $options can be a node-set (xsl:copy-of) or static XML.
	If the option has one of the following attributes, they will be used as the @value in the HTML (in this order of preference)
		@handle, @id, @link-id, @link-handle, @value
	
	Therefore acceptable with-param examples can be in the form:
	
		<xsl:with-param name="options" select="'days'"/> (return a list of 31 days)
		
		<xsl:with-param name="options" select="/data/datasource/entry/tags/item"/> (build a list of tags)
		
		<xsl:with-param name="options">
			<item handle="hello">Hello</item>
			<item handle="world">World</item>
		</xsl:with-param>
	
		<xsl:with-param name="options">
			<option>Hello</option>
			<option>World</option>
		</xsl:with-param>
		
		<xsl:with-param name="options">
			<option value="">Please select a tag:</option>
			<xsl:copy-of select="/data/datasource/entry/tags/item"/>
		</xsl:with-param>	
-->
<xsl:template name="form:select">
	<xsl:param name="event" select="$form:event"/>
	<xsl:param name="handle"/>
	<xsl:param name="section" select="'fields'"/>
	<xsl:param name="value"/>
	<xsl:param name="class"/>
	<xsl:param name="title"/>
	<xsl:param name="options"/>
	<xsl:param name="allow-multiple"/>

	<xsl:variable name="initial-value">
		<xsl:choose>
			<xsl:when test="count(exsl:node-set($value)/*) &gt; 1">
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
		
		<xsl:if test="$allow-multiple">
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
				
				<xsl:when test="string($options)='days'">
					<option value="">Day</option>
					<xsl:call-template name="form:incrementor">
						<xsl:with-param name="start" select="'1'"/>
						<xsl:with-param name="iterations" select="31"/>
					</xsl:call-template>
				</xsl:when>
				
				<xsl:when test="string($options)='months'">
					<option value="">Month</option>
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
				
				<xsl:when test="string(substring($options, 1, 5)) = 'years'">
					<option value="">Year</option>
					<xsl:choose>
						<xsl:when test="substring($options, 6, 1) = '-'">
							<xsl:call-template name="form:incrementor">
								<xsl:with-param name="start" select="$this-year"/>
								<xsl:with-param name="iterations" select="number(substring-after($options,'-') + 1)"/>
								<xsl:with-param name="direction" select="'-'"/>
							</xsl:call-template>
						</xsl:when>
						<xsl:when test="substring($options, 6, 1) = '+'">
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
							<option>a
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
				
				<xsl:if test="($event and $option-value=exsl:node-set($postback-value)/value) or (not($event) and $option-value=exsl:node-set($initial-value)/*)">
					<xsl:attribute name="selected"><xsl:text>selected</xsl:text></xsl:attribute>
				</xsl:if>
				
				<xsl:value-of select="text()"/>
			</option>
			
		</xsl:for-each>
		
  </xsl:element>

</xsl:template>

<xsl:template name="form:radiobutton-list">
	<xsl:param name="event" select="$form:event"/>
	<xsl:param name="handle"/>
	<xsl:param name="section" select="'fields'"/>
	<xsl:param name="value"/>
	<xsl:param name="class"/>
	<xsl:param name="title"/>
	<xsl:param name="options"/>
	
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
					<xsl:with-param name="value" select="@value | ."/>
					<xsl:with-param name="existing-value">
						<xsl:if test="@selected">
							<xsl:value-of select="@value | ."/>
						</xsl:if>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:with-param>
		</xsl:call-template>
		
	</xsl:for-each>
	
</xsl:template>

<xsl:template name="form:checkbox-list">
	<xsl:param name="event" select="$form:event"/>
	<xsl:param name="handle"/>
	<xsl:param name="section" select="'fields'"/>
	<xsl:param name="value"/>
	<xsl:param name="class"/>
	<xsl:param name="title"/>
	<xsl:param name="options"/>
	
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
					<xsl:with-param name="allow-multiple-value" select="@value | ."/>
					<xsl:with-param name="checked">
						<xsl:if test="@selected">yes</xsl:if>
					</xsl:with-param>
					<xsl:with-param name="existing-value">
						<xsl:value-of select="@value | ."/>
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
Name: control-is-valid
Description: returns whether a field is valid or not
Returns: boolean (string "true|false")
Parameters:
* event (mandatory, XPath) XPath expression to the specific event within the page <events> node
* handle (mandatory, string) handle of a Symphony field name
-->
<xsl:template name="form:control-is-valid">
	<xsl:param name="event" select="$form:event"/>
	<xsl:param name="handle"/>
	<xsl:param name="section"/>
	
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
Name: control-name
Description: returns a keyed field name for use in HTML @name attributes
Returns: string
Parameters:
* handle (mandatory, string) handle of a Symphony field name
* section (optional, string) custom key section. Defaults to "fields" (the Symphony default)
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
	
	<xsl:value-of select="concat($section, '[', $handle, ']')"/>
</xsl:template>

<!--
Name: control-id
Description: returns a sanitised version of a field's @name for use as a unique @id attribute
Returns: string
Parameters:
* name (mandatory, string) form field's @name attribute e.g. "fields[title]"
-->
<xsl:template name="form:control-id">
	<xsl:param name="name"/>
		
	<xsl:value-of select="translate(translate($name, '[', '-'),']','')"/>
</xsl:template>

<!--
Name: postback-value
Description: determines the postback value of a control if an Event has been triggered
Returns: string
Parameters:
* event (mandatory, XPath) XPath expression to the specific event within the page <events> node
* handle (mandatory, string) handle of a Symphony field name
* section (optional, string) custom key section. Defaults to "fields" (the Symphony default)
-->
<xsl:template name="form:postback-value">
	<xsl:param name="event" select="$form:event"/>
	<xsl:param name="handle"/>
	<xsl:param name="section"/>
	
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
			<xsl:value-of select="normalize-space($event/entry[@section-handle=$section-handle and @index-key=$index-key]/post-values/*[name()=$handle])"/>
		</xsl:when>
		<xsl:when test="$section!='fields'">
			<xsl:value-of select="normalize-space($event/entry[@section-handle=$section-handle]/post-values/*[name()=$handle])"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:for-each select="$event/post-values/*[name()=$handle]">
				<value><xsl:value-of select="normalize-space(.)"/></value>
			</xsl:for-each>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!--
Name: section-handle
Description: increases or decreases a number between two bounds
Returns: a nodeset of <option> elements
Parameters:
* start (mandatory, string) start number
* iterations (mandatory, string) number of iterations
* direction (optional, string) direction of increment. Defaults to "+"
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

<!-- TODO: document -->
<xsl:template name="form:section-index-key">
	<xsl:param name="section"/>
	
	<xsl:if test="contains($section,'[')">
		<xsl:value-of select="substring-after(substring-before($section, ']'),'[')"/>
	</xsl:if>
</xsl:template>

<!--
Name: incrementor
Description: increases or decreases a number between two bounds
Returns: a nodeset of <option> elements
Parameters:
* start (mandatory, string) start number
* iterations (mandatory, string) number of iterations
* direction (optional, string) direction of increment. Defaults to "+"
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

</xsl:stylesheet>