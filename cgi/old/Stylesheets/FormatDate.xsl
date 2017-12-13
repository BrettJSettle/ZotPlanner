<!-- 
 Copyright 1995-2012 Ellucian Company L.P. and its affiliates. 
 $Id: //Tuxedo/RELEASE/Product/webroot/FormatDate.xsl#2 $ -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"> 

<!-- 
This file is included in each of the worksheet stylesheets like this:
   <xsl:include href="FormatDate.xsl" />
The date format must be in the /Report node as specified below.
Four date formats are supported:
  DMY=12/31/2009 
  YMD=2009/12/31 
  DMY=31/12/2009
  DXY=31-Dec-2009
-->

<xsl:template name="FormatDate">	
<xsl:param name="pDate"/>
  <xsl:variable name="vDateFormat" select="/Report/@rptDateFormat"/>
  <xsl:variable name="vYear"  select="substring($pDate,1,4)"/>
  <xsl:variable name="vMonth" select="substring($pDate,5,2)"/>
  <xsl:variable name="vDay"   select="substring($pDate,7,2)"/>

  <xsl:choose>

    <xsl:when test="$vDateFormat='DMY'"> <!-- Europe/Australia/etc - 31/12/2009-->
     <xsl:value-of select="concat($vDay,'/',$vMonth,'/',$vYear)"/>
    </xsl:when>
  
    <xsl:when test="$vDateFormat='DXY'"> <!-- Europe/Australia/etc - 31-Dec-2009-->
     <xsl:choose>
       <xsl:when test="$vMonth='01'"><xsl:value-of select="concat($vDay,'-','Jan','-',substring($vYear,1,4))"/></xsl:when>
       <xsl:when test="$vMonth='02'"><xsl:value-of select="concat($vDay,'-','Feb','-',substring($vYear,1,4))"/></xsl:when>
       <xsl:when test="$vMonth='03'"><xsl:value-of select="concat($vDay,'-','Mar','-',substring($vYear,1,4))"/></xsl:when>
       <xsl:when test="$vMonth='04'"><xsl:value-of select="concat($vDay,'-','Apr','-',substring($vYear,1,4))"/></xsl:when>
       <xsl:when test="$vMonth='05'"><xsl:value-of select="concat($vDay,'-','May','-',substring($vYear,1,4))"/></xsl:when>
       <xsl:when test="$vMonth='06'"><xsl:value-of select="concat($vDay,'-','Jun','-',substring($vYear,1,4))"/></xsl:when>
       <xsl:when test="$vMonth='07'"><xsl:value-of select="concat($vDay,'-','Jul','-',substring($vYear,1,4))"/></xsl:when>
       <xsl:when test="$vMonth='08'"><xsl:value-of select="concat($vDay,'-','Aug','-',substring($vYear,1,4))"/></xsl:when>
       <xsl:when test="$vMonth='09'"><xsl:value-of select="concat($vDay,'-','Sep','-',substring($vYear,1,4))"/></xsl:when>
       <xsl:when test="$vMonth='10'"><xsl:value-of select="concat($vDay,'-','Oct','-',substring($vYear,1,4))"/></xsl:when>
       <xsl:when test="$vMonth='11'"><xsl:value-of select="concat($vDay,'-','Nov','-',substring($vYear,1,4))"/></xsl:when>
       <xsl:when test="$vMonth='12'"><xsl:value-of select="concat($vDay,'-','Dec','-',substring($vYear,1,4))"/></xsl:when>
       <xsl:otherwise>               <xsl:value-of select="concat($vDay,'-','???','-',substring($vYear,1,4))"/></xsl:otherwise>
     </xsl:choose>
    </xsl:when>
  
    <xsl:when test="$vDateFormat='YMD'"> <!-- China etc - 2009/12/31-->
     <xsl:value-of select="concat($vYear,'/',$vMonth,'/',$vDay)"/>
    </xsl:when>
  
    <xsl:otherwise> <!-- test="$vDateFormat='MDY'"> - USA format - 12/31/2009-->
     <xsl:value-of select="concat($vMonth,'/',$vDay,'/',$vYear)"/>
    </xsl:otherwise> 
  </xsl:choose>
</xsl:template>

</xsl:stylesheet>
