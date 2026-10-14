<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:local="http://www.mycore.de/xslt/mirlocal/metadata-box/mods/identifier"
  xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:mcracl="http://www.mycore.de/xslt/acl"
  xmlns:mcrclass="http://www.mycore.de/xslt/classification"
  xmlns:mcri18n="http://www.mycore.de/xslt/i18n"
  xmlns:mcrproperty="http://www.mycore.de/xslt/property"
  xmlns:mirobject="http://www.mycore.de/xslt/mirobject"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:variable name="local:resolvers" as="map(xs:string, xs:string)" select="map {
    'doi': string(mcrproperty:get('MCR.DOI.Resolver.MasterURL')),
    'hdl': string(mcrproperty:get('MCR.Handle.Resolver.MasterURL')),
    'scopus': string(mcrproperty:get('MCR.Scopus.Backlink')),
    'urn': 'https://nbn-resolving.org/',
    'zdbid': 'https://ld.zdb-services.de/resource/'
  }" />

  <xsl:template match="field[@name='identifier']" mode="metadata-box-field">
    <xsl:param name="object" as="element(mycoreobject)" />
    <xsl:variable name="mods" select="mirobject:mods($object)" />

    <xsl:variable name="identifiers" select="$mods/mods:identifier" />
    <xsl:variable name="identifier-categories" select="
      document('classification:metadata:-1:children:identifier')/mycoreclass/categories"
    />
    <xsl:for-each select="$identifier-categories//category[@ID != 'intern' and @ID != 'issn']">
      <xsl:apply-templates mode="identifier" select="$identifiers[@type = current()/@ID]" />
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="field[@name='identifier.issn']" mode="metadata-box-field">
    <xsl:param name="object" as="element(mycoreobject)" />
    <xsl:variable name="mods" select="mirobject:mods($object)" />

    <xsl:for-each select="$mods/mods:identifier[@type='issn']">
      <xsl:call-template name="meta-row">
        <xsl:with-param name="label" select="mcri18n:translate('mir.identifier.issn')" />
        <xsl:with-param name="value" select="text()" />
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="mods:identifier" mode="identifier">
    <xsl:variable name="type" select="string(@type)" />
    <xsl:variable name="category" select="mcrclass:category('identifier', $type)" />
    <xsl:variable name="category-label" select="string(mcrclass:current-label-text($category))" />
    <xsl:call-template name="meta-row">
      <xsl:with-param name="label" select="
        if (empty($category))
        then mcri18n:translate-with-params('component.mods.metaData.dictionary.identifier.other', $type)
        else if ($category-label) then $category-label
        else $type
      " />
      <xsl:with-param name="value" select="." />
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mods:identifier[@type='intern_old']" mode="identifier">
    <xsl:if test="not(mcracl:is-current-user-in-role('guest'))">
      <xsl:call-template name="meta-row">
        <xsl:with-param name="label" select="mcri18n:translate(concat('component.mods.metaData.dictionary.identifier.',@type))" />
        <xsl:with-param name="value" select="." />
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template match="mods:identifier[@type = 'uri' or map:contains($local:resolvers, @type)]" mode="identifier">
    <xsl:variable name="is-ppn" select="local:is-ppn(.)" />
    <xsl:call-template name="meta-row">
      <xsl:with-param name="label-key" select="
        'component.mods.metaData.dictionary.identifier.' || (if ($is-ppn) then 'ppn' else @type)
      " />
      <xsl:with-param name="value">
        <a href="{local:identifier-href(.)}">
          <xsl:if test="$is-ppn">
            <xsl:attribute name="class" select="'ppn'" />
          </xsl:if>
          <xsl:value-of select="local:identifier-text(.)" />
        </a>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:function name="local:is-ppn" as="xs:boolean">
    <xsl:param name="identifier" as="element(mods:identifier)" />
    <xsl:sequence select="contains($identifier, 'ppn') or contains($identifier, 'PPN')" />
  </xsl:function>

  <xsl:function name="local:identifier-href" as="xs:string">
    <xsl:param name="identifier" as="element(mods:identifier)" />

    <xsl:variable name="value" select="string($identifier)" />
    <xsl:variable name="resolver" select="$local:resolvers($identifier/@type)" />
    <xsl:sequence select="
      if (local:is-ppn($identifier) and contains($value, 'uri.gbv.de/')) then $value || '?format=redirect'
      else if (contains($value, 'http') or empty($resolver)) then $value
      else $resolver || $value
    " />
  </xsl:function>

  <xsl:function name="local:identifier-text" as="xs:string">
    <xsl:param name="identifier" as="element(mods:identifier)" />

    <xsl:variable name="value" select="string($identifier)" />
    <xsl:sequence select="
      if (contains($value, 'PPN=')) then substring-after($value, 'PPN=')
      else if (contains($value, ':ppn:')) then substring-after($value, ':ppn:')
      else $value
    " />
  </xsl:function>

</xsl:stylesheet>
