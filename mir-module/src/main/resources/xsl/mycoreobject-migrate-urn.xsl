<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:mcrurn="xalan://org.mycore.urn.MCRXMLFunctions"
  xmlns:mcrurnman="xalan://org.mycore.mir.migration.MIRMigration2017_06"
  exclude-result-prefixes="mods xlink mcrurn mcrurnman">
  <xsl:include href="copynodes.xsl" />

  <xsl:template match="//mods:mods">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*"/>
      <xsl:if test="not(mods:identifier[@type='urn']) and /mycoreobject/structure/derobjects/derobject">
        <xsl:variable name="derivateID"
            select="/mycoreobject/structure/derobjects/derobject[mcrurn:hasURNDefined(@xlink:href)]/@xlink:href"/>
        <xsl:if test="$derivateID">
          <mods:identifier type="urn">
            <xsl:value-of select="mcrurnman:getURNforDerivate($derivateID)"/>
          </mods:identifier>
        </xsl:if>
        <xsl:if test="count(/mycoreobject/structure/derobjects/derobject) &gt; 1">
          <xsl:message>
            There are multiple Derivates for <xsl:value-of select="/mycoreobject/@ID" />
          </xsl:message>
        </xsl:if>
      </xsl:if>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>