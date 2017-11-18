<!-- 
 Copyright 1995-2012 Ellucian Company L.P. and its affiliates. 
 $Id: //Tuxedo/RELEASE/Product/webroot/CommonTemplates.xsl#2 $ -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"> 

<!-- 
This file is included in each of the worksheet stylesheets like this:
   <xsl:include href="CommonTemplates.xsl" />
-->

<xsl:template name="FormatNoteDate">	
    <xsl:call-template name="FormatDate">
		<xsl:with-param name="pDate" select="@Note_date" />
    </xsl:call-template>
</xsl:template>
<xsl:template name="FormatXptDate">	
    <xsl:call-template name="FormatDate">
		<xsl:with-param name="pDate" select="@Date" />
    </xsl:call-template>
</xsl:template>

<xsl:template name="FormatRuleXptDate">	
    <xsl:call-template name="FormatDate">
		<xsl:with-param name="pDate" select="key('XptKey',@Id_num)/@Date" />
    </xsl:call-template>
</xsl:template>

<xsl:template name="tFormatNumber">
<xsl:param name="iNumber" />
<xsl:param name="sRoundingMethod" />
  <xsl:choose>
    <!-- If the number contains a range (eg: 0:4) -->
    <xsl:when test="contains ($iNumber, ':') ">
	 <xsl:value-of select="$iNumber" />
    </xsl:when>
    <xsl:otherwise>
	 <xsl:value-of select="format-number($iNumber, $sRoundingMethod)" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- Replace one string with another -->
<xsl:template name="globalReplace">
  <xsl:param name="outputString"/>
  <xsl:param name="target"/>
  <xsl:param name="replacement"/>
  <xsl:choose>
    <xsl:when test="contains($outputString,$target)">
      <xsl:value-of select="concat(substring-before($outputString,$target),$replacement)"/>
      <xsl:call-template name="globalReplace">
        <xsl:with-param name="outputString" select="substring-after($outputString,$target)"/>
        <xsl:with-param name="target"       select="$target"/>
        <xsl:with-param name="replacement"  select="$replacement"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$outputString"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="tAsterisks">
<xsl:param name="bytes_to_remove" />
<xsl:variable name="decrement" select="$bytes_to_remove - 1" />
<xsl:if test="$decrement &gt; -1">*<xsl:call-template name="tAsterisks"><xsl:with-param name="bytes_to_remove" select="$decrement" /></xsl:call-template></xsl:if>
</xsl:template>
            
<xsl:template name="tFillAsterisks">
<xsl:param name="string_length" />
<xsl:variable name="decrement" select="$string_length - 1" />
<xsl:if test="$decrement &gt; -1">*<xsl:call-template name="tFillAsterisks"><xsl:with-param name="string_length" select="$decrement" /></xsl:call-template></xsl:if>
</xsl:template>
            
</xsl:stylesheet>
