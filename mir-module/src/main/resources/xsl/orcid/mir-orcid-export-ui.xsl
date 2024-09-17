<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="xsl">

  <xsl:template name="render-export-to-orcid-modal">
    <div id="exportToOrcidModal" class="modal fade" tabindex="-1"
      aria-labelledby="exportToOrcidModalLabel" aria-hidden="true" role="dialog">
      <div class="modal-dialog modal-lg">
        <div class="modal-content">
          <div class="modal-header">
            <h5 id="exportToOrcidModalLabel" class="modal-title">
              <xsl:value-of select="document('i18n:mir.orcid.publication.export.modal.title')"/>
            </h5>
            <button class="btn-close" type="button" data-bs-dismiss="modal" aria-label="Close"></button>
          </div>
          <div class="modal-body">
            <div id="alertDiv" class="alert alert-danger" role="alert">
              <xsl:value-of select="document('i18n:mir.orcid.publication.export.error.generic')"/>
            </div>
            <div class="form-group">
              <label for="orcidProfileSelect">
                <xsl:value-of select="document('i18n:mir.orcid.publication.export.description')"/>
              </label>   
              <select class="form-control mt-1" id="orcidProfileSelect">
                <option value="" selected="selected">
                  <xsl:value-of select="document('i18n:mir.select')"/>
                </option>
              </select>
            </div>
          </div>
          <div class="modal-footer">
            <button id="exportToOrcidBtn" class="btn btn-primary" type="button">
              <xsl:value-of select="document('i18n:mir.orcid.publication.export.action.confirm')"/>
            </button>
            <button class="btn btn-secondary" type="button" data-bs-dismiss="modal">
              <xsl:value-of select="document('i18n:button.cancel')"/>
            </button>
          </div>
        </div>
      </div>
    </div>
  </xsl:template>

  <xsl:template name="render-export-to-orcid-menu-item">
    <xsl:param name="objectId"/>
    <xsl:param name="disabled" select="true()"/>
    <xsl:if test="$objectId">
      <li id="exportToOrcidMenuItem">
        <a id="openExportToOrcidModal" class="dropdown-item" role="menuitem" data-object-id="{$objectId}">
          <xsl:attribute name="class">
            <xsl:choose>
              <xsl:when test="$disabled">
                <xsl:text>dropdown-item open-export-orcid-modal disabled</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>dropdown-item open-export-orcid-modal</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
          <xsl:value-of select="document('i18n:mir.orcid.publication.export.action.trigger')"/>
        </a>
      </li>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
