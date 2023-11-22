<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="xml"
              media-type="image/svg+xml"
              doctype-public="-//W3C//DTD SVG 1.1//EN"
              doctype-system="http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd"/>

  <xsl:param name="extension" select="'?'"/>

  <xsl:template match="*">

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

    <xsl:call-template name="generate-download-svg">
      <xsl:with-param name="type" select="$value"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="generate-download-svg">
    <xsl:param name="type"/>

    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 36.88 41">
      <defs>
        <style>
          .cls-1{fill:#36a9e1;} .cls-2{fill:#c4c4c4;} .cls-3{fill:#00487d;}
        </style>
      </defs>
      <title>
        <xsl:value-of select="concat('download_', $type)"/>
      </title>

      <path class="cls-1" d="M10.2,38.43c0,.06,0,0,0,0h0Z"/>
      <path class="cls-2"
            d="M29,.5H10.31a2,2,0,0,0-1.37.54,1.79,1.79,0,0,0-.57,1.31V8.31A1,1,0,0,1,9,8.11a1,1,0,0,1,.7.27V2.25a.49.49,0,0,1,.19-.39.61.61,0,0,1,.45-.15L29,1.69l.25,3.69H35c.08,0,.11.4.11.55l0,32.69a.61.61,0,0,1-.19.44.65.65,0,0,1-.45.19h-14a1,1,0,0,1,.2.56,1,1,0,0,1-.29.68H34.45a2,2,0,0,0,1.37-.54,1.8,1.8,0,0,0,.57-1.31L36.36,6A3.21,3.21,0,0,0,35,3.52l-3.31-2.2A5.65,5.65,0,0,0,29,.5Zm1.46,3.88-.15-2.29a2.83,2.83,0,0,1,.67.36l2.83,1.93Z"/>
      <path class="cls-2"
            d="M8.23,34.34s.11,0,.16.07a1,1,0,0,0,.64.27,1,1,0,0,0,.72-.33h0l5.92-6.14a1.12,1.12,0,0,0,0-1.54,1,1,0,0,0-1.48,0L10,31V11.72a1,1,0,1,0-2,0V31.07l-4.25-4.4a1,1,0,0,0-1.48,0,1.12,1.12,0,0,0,0,1.54Z"/>
      <path class="cls-3" d="M17,38.81H1a1,1,0,1,0,0,2H17a1,1,0,1,0,0-2Z"/>
      <text class="cls-3" x="11" y="20" font-size="11"
            font-family="Lato,-apple-system,BlinkMacSystemFont,Segoe UI,Roboto,Helvetica Neue,Arial,sans-serif,Apple Color Emoji,Segoe UI Emoji,Segoe UI Symbol">
        <xsl:value-of select="concat('.', $type)"/>
      </text>
    </svg>
  </xsl:template>
</xsl:stylesheet>
