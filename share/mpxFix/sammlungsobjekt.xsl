<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 version="1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://www.mpx.org/mpx"
 xmlns:mpx="http://www.mpx.org/mpx">

 <xsl:template
  match="/mpx:museumPlusExport/mpx:sammlungsobjekt/mpx:personKörperschaftRef">
  <xsl:copy>
    <xsl:variable name="kueId"
     select="/mpx:museumPlusExport/mpx:personKörperschaft[ mpx:nennform = current() or mpx:name = current()]/@kueId"/>
   <xsl:if test="not (@id) and count ($kueId)= 1">
    <!-- do not confuse people or records with the same name-->
    <xsl:attribute name="id">
     <xsl:value-of select="$kueId"/>
     </xsl:attribute>
    <xsl:message>
     <xsl:text>add //mpx:perKörRed/@id</xsl:text>
     <xsl:value-of select="$kueId"/>
     <xsl:text>-</xsl:text>
     <xsl:value-of select="current()"/>
    </xsl:message>
   </xsl:if>

   <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
 </xsl:template>


</xsl:stylesheet>