<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mirconfig="http://www.mycore.de/xslt/mirconfig"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:import href="resource:xslt/mir/solr/response/actions/helpers.xsl" />

  <xsl:include href="resource:xslt/default-parameters.xsl" />
  <xsl:include href="resource:xslt/mir/orcid/export.xsl" />
  <xsl:include href="xslInclude:functions" />
  <xsl:include href="xslInclude:resultactions" />

  <xsl:template match="/">
    <actions>
      <xsl:call-template name="result-actions">
        <xsl:with-param name="names" select="mirconfig:get-list('MIR.ResultActions', ())" />
        <xsl:with-param name="doc" select="response/doc" />
        <xsl:with-param name="object-id" select="string(response/doc/str[@name='id'])" />
      </xsl:call-template>
    </actions>
  </xsl:template>

  <xsl:template name="basketLink">
    <xsl:param name="identifier" />
    <xsl:param name="dropdown" />

    <a class="hit_option hit_to_basket" data-identifier="{$identifier}" data-dropdown="{$dropdown}" />
  </xsl:template>

</xsl:stylesheet>
