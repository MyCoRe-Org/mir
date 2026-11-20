<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mcri18n="http://www.mycore.de/xslt/i18n"
  xmlns:mirconfig="http://www.mycore.de/xslt/mirconfig"
  xmlns:mirmods="http://www.mycore.de/xslt/mirmods"
  xmlns:mirobject="http://www.mycore.de/xslt/mirobject"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:import href="xslImport:modsmeta:mir/object-page/boxes/actions/box.xsl" />
  <xsl:import href="resource:xslt/mir/object-page/boxes/actions/helpers.xsl" />
  <xsl:include href="xslInclude:objectactions" />

  <xsl:template match="/">
    <xsl:variable name="object" select="mycoreobject" />
    <xsl:variable name="genres" select="mirmods:genres(mirobject:mods($object))" />

    <xsl:call-template name="object-action-context">
      <xsl:with-param name="names" select="mirconfig:get-list('MIR.ObjectActions', $genres)" />
      <xsl:with-param name="object" select="$object" />
      <xsl:with-param name="genres" select="$genres" />
      <xsl:with-param name="mods-type" select="string($mods-type)" />
    </xsl:call-template>
    <xsl:apply-imports />
  </xsl:template>

  <xsl:template match="mycoreobject" mode="object-action-box">
    <xsl:param name="actions" as="element(action)*" tunnel="yes" />
    <xsl:param name="object-id" as="xs:string" tunnel="yes" />

    <div id="mir-edit">
      <div class="btn-group d-flex">
        <xsl:call-template name="object-basket-button">
          <xsl:with-param name="object-id" select="$object-id" />
        </xsl:call-template>
        <xsl:if test="exists($actions)">
          <div class="btn-group w-100">
            <a href="#" class="btn btn-secondary btn-sm dropdown-toggle" data-bs-toggle="dropdown">
              <i class="fas fa-cog">
                <xsl:value-of select="' '" />
              </i>
              <xsl:value-of select="concat(' ', mcri18n:translate('mir.actions'))" />
            </a>
            <ul class="dropdown-menu dropdown-menu-end">
              <xsl:call-template name="object-actions" />
            </ul>
          </div>
        </xsl:if>
      </div>
      <xsl:call-template name="object-action-dialogs" />
    </div>
  </xsl:template>

  <xsl:template name="object-basket-button">
    <xsl:param name="object-id" />

    <xsl:variable name="basket-url" select="$ServletsBaseURL || 'MCRBasketServlet?type=objects&amp;redirect=' || encode-for-uri($RequestURL) || '&amp;id=' || $object-id" />
    <xsl:choose>
      <xsl:when test="exists(document('basket:objects:' || $object-id)/entry/@uri)">
        <a class="btn btn-primary btn-sm w-100" href="{$basket-url}&amp;action=remove">
          <i class="fas fa-minus">
            <xsl:value-of select="' '" />
          </i>
          <xsl:value-of select="concat(' ', mcri18n:translate('basket.remove'))" />
        </a>
      </xsl:when>
      <xsl:otherwise>
        <a class="btn btn-primary btn-sm w-100" href="{$basket-url}&amp;action=add&amp;uri=mcrobject:{$object-id}">
          <i class="fas fa-plus">
            <xsl:value-of select="' '" />
          </i>
          <xsl:value-of select="concat(' ', mcri18n:translate('basket.add'))" />
        </a>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
