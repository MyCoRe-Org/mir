<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:output method="xml"
    media-type="image/svg+xml"
    doctype-public="-//W3C//DTD SVG 1.1//EN"
    doctype-system="http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd"/>

  <xsl:param name="extension" select="'?'"/>

  <xsl:template match="@*|node()|comment()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()|comment()"/>
      <xsl:if test="local-name() = 'text'">
        <xsl:variable name="value">
          <xsl:choose>
            <xsl:when test="string-length($extension) &lt; 5">
              <xsl:value-of select="$extension"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="substring($extension, 0, 4)"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="concat('.',$value)"/>
      </xsl:if>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
