<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:mods="http://www.loc.gov/mods/v3">
  <xsl:include href="copynodes.xsl" />

  <xsl:template match="mods:name[@valueURI]">
    <xsl:choose>
      <xsl:when test="(@type = 'personal' or @type = 'corporate') and (starts-with(@authorityURI, 'http://d-nb.info/gnd/') or starts-with(@authorityURI, 'http://www.viaf.org/'))">
        <xsl:choose>
          <xsl:when test="starts-with(@authorityURI, 'http://d-nb.info/gnd/')">
            <xsl:copy>
              <xsl:apply-templates select="@* | *"/>
              <mods:nameIdentifier type="gnd" typeURI="http://d-nb.info/gnd/"><xsl:value-of select="substring-after(@valueURI, 'http://d-nb.info/gnd/')" /></mods:nameIdentifier>
            </xsl:copy>
          </xsl:when>
          <xsl:when test="starts-with(@authorityURI, 'http://www.viaf.org/')">
            <xsl:copy>
              <xsl:apply-templates select="@* | *"/>
              <mods:nameIdentifier type="viaf" typeURI="http://www.viaf.org/"><xsl:value-of select="substring-after(@valueURI, 'http://www.viaf.org/')" /></mods:nameIdentifier>
            </xsl:copy>
          </xsl:when>
          <xsl:otherwise>
            <xsl:copy-of select="."/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="@valueURI">
    <xsl:choose>
      <xsl:when test="(name(..) = 'mods:name') and (../@type = 'personal' or ../@type = 'corporate') and (starts-with(., 'http://d-nb.info/gnd/') or starts-with(., 'http://www.viaf.org/'))">
      </xsl:when>
    <xsl:otherwise>
      <xsl:copy-of select="."/>
    </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="@authorityURI">
    <xsl:choose>
      <xsl:when test="(name(..) = 'mods:name') and (../@type = 'personal' or ../@type = 'corporate') and (starts-with(., 'http://d-nb.info/gnd/') or starts-with(., 'http://www.viaf.org/'))">
      </xsl:when>
    <xsl:otherwise>
      <xsl:copy-of select="."/>
    </xsl:otherwise>
  </xsl:choose>
  </xsl:template>

</xsl:stylesheet>