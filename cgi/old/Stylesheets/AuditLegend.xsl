<!-- 
 Copyright 1995-2012 Ellucian Company L.P. and its affiliates. 
 $Id: //Tuxedo/RELEASE/Product/webroot/AuditLegend.xsl#2 $ -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"> 

<!-- //////////////////////////////////////////////////////////////////////// -->
<!-- LEGEND -->
<!-- This template is shared by the academic, athletic and fin-aid worksheets 
     If you have the need, you can use a choose on the AuditType to hide a field
     or to show a different field. 
     It is recommended that all changes be made in this file for all audit types
     instead of creating separate xsl files.
     <xsl:when test="/Report/Audit/AuditHeader/@AuditType = 'FA'"> Financial Aid
     <xsl:when test="/Report/Audit/AuditHeader/@AuditType = 'AE'"> Athletic Eligibility
     <xsl:when test="/Report/Audit/AuditHeader/@AuditType = 'AA'"> Academic Audit
-->
<!-- //////////////////////////////////////////////////////////////////////// -->

<xsl:template name="tLegend">
   <!-- ========================= LEGEND =========================== -->
   <br />
   <table border="0" cellspacing="0" cellpadding="0" width="100%" class="LegendTitle">                                    
      <tr>
         <td class="BorderDark">
         </td>
      </tr>
      <tr>
         <td class="BorderLight">
         </td>
      </tr>
      <tr>
         <td align="left" valign="top">
         <table border="0" cellspacing="0" cellpadding="4" width="100%">
            <tr>
               <td align="left" valign="middle">
               <span class="LegendTitle">
                  Legend
               </span>
               </td>
            </tr>
         </table>
         </td>
      </tr>
      <tr>
         <td class="BorderLight">
         </td>
      </tr>
      <tr>
         <td class="BorderDark">
         </td>
      </tr>
   </table>
   
   <table border="0" cellspacing="0" cellpadding="0" width="100%">
      <tr>
         <td align="left" valign="top">
         <table border="0" cellspacing="0" cellpadding="4" width="100%">
            <tr>
               <td class="LegendItem">
                  <img src="common/dwcheckyes.png"  ondragstart="window.event.returnValue=false;"/>
               </td>
               <td class="LegendLabel">
                  Complete
               </td>
               <td class="LegendItem">
                  <img src="common/dwcheck98.png"  ondragstart="window.event.returnValue=false;"/>
               </td> 
               <td class="LegendLabel">
                  Complete except for classes in-progress
               </td>
               <td class="LegendItem">
                  (T)
               </td>
               <td class="LegendLabel">
                  Transfer Class
               </td>
            </tr>
            <tr>
               <td class="LegendItem">
                  <img src="common/dwcheckno.png"  ondragstart="window.event.returnValue=false;"/>
               </td>
               <td class="LegendLabel">
                  Not Complete
               </td>
               <td class="LegendItem">
                  <img src="common/dwcheck99.png"  ondragstart="window.event.returnValue=false;"/>
               </td>
               <td class="LegendLabel">
                  Nearly complete - see advisor
               </td>
               <td class="LegendItem">
                  @
               </td>
               <td class="LegendLabel">
                  Any course number
               </td>
            </tr>
         </table>
         </td>
      </tr>
   </table>
</xsl:template>

</xsl:stylesheet>