<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- In case of versioned labels, clone given category for each version -->

  <xsl:output method="xml" indent="yes" />

  <xsl:include href="copynodes.xsl" />

  <xsl:template match="category[valid[label]]">
    <xsl:for-each select="valid[label]">
      <xsl:copy>
        <xsl:copy-of select="@*" />
        <category>
          <xsl:copy-of select="../@*" />
          <xsl:copy-of select="../label|label" />
          <xsl:apply-templates select="../category|../valid[not(label)]" />
        </category>
      </xsl:copy>
    </xsl:for-each>
  </xsl:template>
  
</xsl:stylesheet>