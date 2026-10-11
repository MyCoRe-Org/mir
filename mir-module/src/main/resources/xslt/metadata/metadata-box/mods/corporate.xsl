<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:local="http://www.mycore.de/xslt/mirlocal/metadata-box/mods/corporate"
  xmlns:mcracl="http://www.mycore.de/xslt/acl"
  xmlns:mirobject="http://www.mycore.de/xslt/mirobject"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:template match="field[@name='corporate']" mode="metadata-box-field">
    <xsl:param name="object" as="element(mycoreobject)" />
    <xsl:variable name="mods" select="mirobject:mods($object)" />

    <xsl:variable name="institutes-uri" select="
      document('classification:metadata:-1:children:mir_institutes')/mycoreclass/label[@xml:lang='x-uri']/@text
    " />

    <xsl:for-each select="$mods/mods:name[@type='corporate'][@ID or @authorityURI=$institutes-uri]">
      <xsl:call-template name="meta-row">
        <xsl:with-param name="label-key" select="local:corporate-label-key(.)" />
        <xsl:with-param name="value">
          <xsl:apply-templates select="." mode="name" />
        </xsl:with-param>
      </xsl:call-template>

      <xsl:if test="@ID">
        <xsl:variable name="ref" select="'#' || @ID" />
        <xsl:if test="not(mcracl:is-current-user-in-role('guest'))">
          <xsl:call-template name="mods-meta-row">
            <xsl:with-param name="nodes" select="../mods:note[@xlink:href = $ref]" />
          </xsl:call-template>
        </xsl:if>
        <xsl:call-template name="mods-meta-row">
          <xsl:with-param name="nodes" select="../mods:location/mods:physicalLocation[@xlink:href = $ref]" />
        </xsl:call-template>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:function name="local:corporate-label-key" as="xs:string">
    <xsl:param name="corporate" as="element(mods:name)" />

    <xsl:variable name="role-code" select="
      $corporate/mods:role/mods:roleTerm[@type='code' and @authority='marcrelator'][1]
    " />

    <xsl:choose>
      <xsl:when test="$role-code and not($corporate/@ID)">
        <xsl:sequence select="'component.mods.metaData.dictionary.institution.' || $role-code || '.label'" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="'component.mods.metaData.dictionary.institution.label'" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

</xsl:stylesheet>
