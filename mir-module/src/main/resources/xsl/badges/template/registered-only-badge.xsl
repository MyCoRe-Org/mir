<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
                xmlns:mods="http://www.loc.gov/mods/v3"
                exclude-result-prefixes="i18n xsl mods">

  <xsl:include href="resource:xsl/badges/template/create-badge-util.xsl" />

  <xsl:param name="MCR.DOI.Resolver.MasterURL" select="''" />

  <!-- Registered only badge -->
  <xsl:template name="register-only-badge">
    <xsl:if test="//mods:classification[contains(@valueURI, 'registerOnly#true')]">
      <xsl:variable name="doi" select="//mods:identifier[@type='doi']" />

      <xsl:call-template name="create-badge">
        <xsl:with-param name="label" select="i18n:translate('mir.badge.registered.only.label')" />
        <xsl:with-param name="color" select="'primary'" />
        <xsl:with-param name="class" select="'mir-abstract-register-only'" />
        <xsl:with-param name="URL">
          <xsl:if test="$doi">
            <xsl:value-of select="concat($MCR.DOI.Resolver.MasterURL, $doi)"/>
          </xsl:if>
        </xsl:with-param>

        <xsl:with-param name="tooltip">
          <xsl:if test="$doi">
            <xsl:value-of select="concat('DOI: ',$doi)"/>
          </xsl:if>
        </xsl:with-param>

      </xsl:call-template>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
