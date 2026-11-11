<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mcracl="http://www.mycore.de/xslt/acl"
  xmlns:mcri18n="http://www.mycore.de/xslt/i18n"
  xmlns:mirconfig="http://www.mycore.de/xslt/mirconfig"
  xmlns:mirmods="http://www.mycore.de/xslt/mirmods"
  xmlns:mirobject="http://www.mycore.de/xslt/mirobject"
  xmlns:mirorcidutil="http://www.mycore.de/xslt/mirorcidutil"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:import href="xslImport:modsmeta:mir/object-page/boxes/actions/box.xsl" />
  <xsl:import href="resource:xslt/mir/object-page/boxes/actions/helpers.xsl" />
  <xsl:include href="resource:xslt/mir/mods/object-types.xsl" />
  <xsl:include href="xslInclude:objectactions" />

  <xsl:template match="/">
    <xsl:variable name="object" select="mycoreobject" />
    <xsl:variable name="genres" select="mirmods:genres(mirobject:mods($object))" />
    <xsl:variable name="names" select="mirconfig:get-list('MIR.ObjectActions', $genres)" />

    <div id="mir-edit">
      <div class="btn-group d-flex">
        <xsl:call-template name="object-basket-button">
          <xsl:with-param name="object-id" select="string($object/@ID)" />
        </xsl:call-template>
        <xsl:if test="exists($names)">
          <div class="btn-group w-100">
            <a href="#" class="btn btn-secondary btn-sm dropdown-toggle" data-bs-toggle="dropdown">
              <i class="fas fa-cog">
                <xsl:value-of select="' '" />
              </i>
              <xsl:value-of select="concat(' ', mcri18n:translate('mir.actions'))" />
            </a>
            <ul class="dropdown-menu dropdown-menu-end">
              <xsl:call-template name="object-actions">
                <xsl:with-param name="names" select="$names" />
                <xsl:with-param name="object" select="$object" />
                <xsl:with-param name="genres" select="$genres" />
                <xsl:with-param name="mods-type" select="string($mods-type)" />
              </xsl:call-template>
            </ul>
          </div>
        </xsl:if>
      </div>
      <xsl:if test="$names = 'register-pi'">
        <xsl:call-template name="register-pi-modal" />
      </xsl:if>
      <xsl:if test="$names = 'orcid-export' and mirorcidutil:is-orcid-enabled() and not(mcracl:is-current-user-guest-user())">
        <xsl:call-template name="render-export-to-orcid-modal" />
        <script type="module" src="{$WebApplicationBaseURL}js/mir/orcid-metadata.js" />
      </xsl:if>
    </div>
    <xsl:apply-imports />
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

  <xsl:template name="register-pi-modal">
    <div class="modal fade" id="modal-pi" tabindex="-1" role="dialog" data-backdrop="static">
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header">
            <h4 class="modal-title" data-i18n="component.pi.register."></h4>
          </div>
          <div class="modal-body">
            <div class="row">
              <div class="col-md-2">
                <i class="fas fa-question-circle"></i>
              </div>
              <div class="col-md-10" data-i18n="component.pi.register.modal.text."></div>
            </div>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary modal-pi-cancel" data-bs-dismiss="modal">
              <xsl:value-of select="mcri18n:translate('component.pi.register.modal.abort')" />
            </button>
            <button type="button" class="btn btn-danger" id="modal-pi-add" data-i18n="component.pi.register.">
            </button>
          </div>
        </div>
      </div>
    </div>
  </xsl:template>

</xsl:stylesheet>
