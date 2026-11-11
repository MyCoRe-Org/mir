<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mcrproperty="http://www.mycore.de/xslt/property"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:template match="action[@name='workflow']" mode="object-action">
    <xsl:param name="object" as="element(mycoreobject)" tunnel="yes" />
    <xsl:param name="write" as="xs:boolean" tunnel="yes" />
    <xsl:param name="edit-url" as="xs:string" tunnel="yes" />

    <xsl:if test="$write and $edit-url != '' and normalize-space(mcrproperty:get('MIR.Workflow.Menu')) = 'true'">
      <xsl:for-each select="$object">
        <xsl:call-template name="listStatusChangeOptions">
          <xsl:with-param name="class" select="'dropdown-item'" />
        </xsl:call-template>
      </xsl:for-each>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
