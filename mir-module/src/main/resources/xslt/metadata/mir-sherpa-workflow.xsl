<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:mcri18n="http://www.mycore.de/xslt/i18n"
                xmlns:mods="http://www.loc.gov/mods/v3"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                exclude-result-prefixes="#all">

  <xsl:import href="xslImport:mirworkflow:metadata/mir-sherpa-workflow.xsl"/>

  <xsl:template match="mycoreobject" mode="creatorSubmittedAdd" priority="20">
    <xsl:call-template name="mir.sherpa.workflow-for-object"/>
  </xsl:template>

  <xsl:template name="mir.sherpa.workflow-for-object">
    <xsl:variable name="hostWithISSN"
                  select="metadata/def.modsContainer/modsContainer/mods:mods/mods:relatedItem[@type='host'][mods:identifier[@type='issn']][1]"/>
    <xsl:choose>
      <xsl:when test="$hostWithISSN">
        <xsl:call-template name="mir.sherpa.workflow-item">
          <xsl:with-param name="issn" select="normalize-space($hostWithISSN/mods:identifier[@type='issn'][1])"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="hostHref"
                      select="metadata/def.modsContainer/modsContainer/mods:mods/mods:relatedItem[@type='host'][@xlink:href][1]/@xlink:href"/>
        <xsl:if test="string-length($hostHref) &gt; 0">
          <xsl:variable name="hostObject" select="document(concat('mcrobject:', $hostHref))"/>
          <xsl:variable name="hostIssn"
                        select="normalize-space($hostObject/mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:identifier[@type='issn'][1])"/>
          <xsl:if test="string-length($hostIssn) &gt; 0">
            <xsl:call-template name="mir.sherpa.workflow-item">
              <xsl:with-param name="issn" select="$hostIssn"/>
            </xsl:call-template>
          </xsl:if>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="mir.sherpa.workflow-item">
    <xsl:param name="issn"/>
    <xsl:variable name="sherpa" select="document(concat('sherpa-policy:', $issn))/sherpa"/>
    <xsl:if test="$sherpa/item/publisherPolicy/permittedOA">
      <xsl:variable name="modalId" select="concat('mir-sherpa-workflow-modal-', generate-id($sherpa/item[1]))"/>
      <li class="mir-sherpa-workflow">
        <button class="btn btn-link p-0 align-baseline" type="button" data-bs-toggle="modal"
                data-bs-target="#{$modalId}">
          <xsl:value-of select="mcri18n:translate('mir.workflow.sherpa.heading')"/>
        </button>
        <div id="{$modalId}" class="modal fade" tabindex="-1" role="dialog"
             aria-labelledby="{concat($modalId, '-title')}" aria-hidden="true">
          <div class="modal-dialog modal-lg" role="document">
            <div class="modal-content">
              <div class="modal-header">
                <h4 class="modal-title" id="{concat($modalId, '-title')}">
                  <xsl:value-of select="mcri18n:translate('mir.workflow.sherpa.heading')"/>
                </h4>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"/>
              </div>
              <div class="modal-body">
                <xsl:for-each select="$sherpa/item[1]">
                  <xsl:call-template name="mir.sherpa.modal-content"/>
                </xsl:for-each>
              </div>
              <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
                  <xsl:value-of select="mcri18n:translate('mir.workflow.sherpa.close')"/>
                </button>
              </div>
            </div>
          </div>
        </div>
      </li>
    </xsl:if>
  </xsl:template>

  <xsl:template name="mir.sherpa.modal-content">
    <dl class="mir-sherpa-summary mt-2 mb-2">
      <xsl:if test="string-length(title) &gt; 0">
        <dt><xsl:value-of select="mcri18n:translate('mir.workflow.sherpa.journal')"/></dt>
        <dd><xsl:value-of select="title"/></dd>
      </xsl:if>
      <xsl:if test="string-length(publisher) &gt; 0">
        <dt><xsl:value-of select="mcri18n:translate('mir.workflow.sherpa.publisher')"/></dt>
        <dd><xsl:value-of select="publisher"/></dd>
      </xsl:if>
      <xsl:if test="string-length(sherpaURL) &gt; 0">
        <dt><xsl:value-of select="mcri18n:translate('mir.workflow.sherpa.record')"/></dt>
        <dd>
          <a href="{sherpaURL}">
            <xsl:value-of select="mcri18n:translate('mir.workflow.sherpa.record.view')"/>
          </a>
        </dd>
      </xsl:if>
      <xsl:if test="publisherPolicy/openAccessProhibited">
        <dt><xsl:value-of select="mcri18n:translate('mir.workflow.sherpa.oa.prohibited')"/></dt>
        <dd>
          <xsl:call-template name="mir.sherpa.value">
            <xsl:with-param name="value" select="publisherPolicy/openAccessProhibited"/>
          </xsl:call-template>
        </dd>
      </xsl:if>
      <xsl:if test="publisherPolicy/policyURL">
        <dt><xsl:value-of select="mcri18n:translate('mir.workflow.sherpa.policy')"/></dt>
        <dd>
          <xsl:for-each select="publisherPolicy/policyURL">
            <a href="{@href}"><xsl:value-of select="."/></a>
            <xsl:if test="position() != last()"><br/></xsl:if>
          </xsl:for-each>
        </dd>
      </xsl:if>
    </dl>
    <div class="mir-sherpa-routes mt-3">
      <ul class="nav nav-tabs" role="tablist">
        <xsl:for-each select="publisherPolicy/permittedOA">
          <xsl:variable name="tabId" select="concat('mir-sherpa-tab-', generate-id())"/>
          <li class="nav-item" role="presentation">
            <a href="#{$tabId}" role="tab" data-bs-toggle="tab" aria-controls="{$tabId}">
              <xsl:attribute name="class">
                <xsl:text>nav-link</xsl:text>
                <xsl:if test="position() = 1"><xsl:text> active</xsl:text></xsl:if>
              </xsl:attribute>
              <xsl:attribute name="aria-selected">
                <xsl:choose>
                  <xsl:when test="position() = 1">true</xsl:when>
                  <xsl:otherwise>false</xsl:otherwise>
                </xsl:choose>
              </xsl:attribute>
              <xsl:value-of select="mcri18n:translate('mir.workflow.sherpa.route')"/>
              <xsl:text> </xsl:text>
              <xsl:value-of select="position()"/>
            </a>
          </li>
        </xsl:for-each>
      </ul>
      <div class="tab-content border-start border-end border-bottom p-3">
      <xsl:for-each select="publisherPolicy/permittedOA">
        <xsl:variable name="tabId" select="concat('mir-sherpa-tab-', generate-id())"/>
        <div id="{$tabId}" role="tabpanel">
          <xsl:attribute name="class">
            <xsl:text>tab-pane fade</xsl:text>
            <xsl:if test="position() = 1"><xsl:text> show active</xsl:text></xsl:if>
          </xsl:attribute>
        <div class="mir-sherpa-route">
          <dl class="mir-sherpa-route-summary mb-2">
            <xsl:call-template name="mir.sherpa.values-row">
              <xsl:with-param name="label" select="mcri18n:translate('mir.workflow.sherpa.articleVersion')"/>
              <xsl:with-param name="values" select="articleVersion/value"/>
            </xsl:call-template>
            <xsl:call-template name="mir.sherpa.values-row">
              <xsl:with-param name="label" select="mcri18n:translate('mir.workflow.sherpa.location')"/>
              <xsl:with-param name="values" select="location/value"/>
            </xsl:call-template>
            <xsl:if test="embargo">
              <dt><xsl:value-of select="mcri18n:translate('mir.workflow.sherpa.embargo')"/></dt>
              <dd><xsl:call-template name="mir.sherpa.embargo-text"/></dd>
            </xsl:if>
            <xsl:if test="license/value">
              <dt><xsl:value-of select="mcri18n:translate('mir.workflow.sherpa.license')"/></dt>
              <dd>
                <xsl:for-each select="license/value">
                  <xsl:value-of select="."/>
                  <xsl:if test="position() != last()">, </xsl:if>
                </xsl:for-each>
              </dd>
            </xsl:if>
            <xsl:if test="additionalFee">
              <dt><xsl:value-of select="mcri18n:translate('mir.workflow.sherpa.additionalFee')"/></dt>
              <dd>
                <xsl:call-template name="mir.sherpa.value">
                  <xsl:with-param name="value" select="additionalFee"/>
                </xsl:call-template>
              </dd>
            </xsl:if>
            <xsl:call-template name="mir.sherpa.values-row">
              <xsl:with-param name="label" select="mcri18n:translate('mir.workflow.sherpa.prerequisites')"/>
              <xsl:with-param name="values" select="prerequisites/value"/>
            </xsl:call-template>
            <xsl:if test="conditions/condition">
              <dt><xsl:value-of select="mcri18n:translate('mir.workflow.sherpa.conditions')"/></dt>
              <dd>
                <span class="text-muted">
                  <xsl:value-of select="mcri18n:translate('mir.workflow.sherpa.originalText')"/>: </span>
                <ul class="mir-sherpa-conditions mb-0">
                  <xsl:for-each select="conditions/condition">
                    <li><xsl:value-of select="."/></li>
                  </xsl:for-each>
                </ul>
              </dd>
            </xsl:if>
            <xsl:if test="publicNotes">
              <dt><xsl:value-of select="mcri18n:translate('mir.workflow.sherpa.publicNotes')"/></dt>
              <dd><xsl:value-of select="publicNotes"/></dd>
            </xsl:if>
          </dl>
        </div>
        </div>
      </xsl:for-each>
      </div>
    </div>
  </xsl:template>

  <xsl:template name="mir.sherpa.embargo-text">
    <xsl:choose>
      <xsl:when test="embargo/@amount">
        <xsl:value-of select="embargo/@amount"/>
        <xsl:text> </xsl:text>
        <xsl:value-of select="mcri18n:translate(concat('mir.workflow.sherpa.', embargo/@units))"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="mcri18n:translate('mir.workflow.sherpa.noEmbargo')"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="mir.sherpa.values-row">
    <xsl:param name="label"/>
    <xsl:param name="values"/>
    <xsl:if test="$values">
      <dt><xsl:value-of select="$label"/></dt>
      <dd>
        <xsl:for-each select="$values">
          <xsl:call-template name="mir.sherpa.value">
            <xsl:with-param name="value" select="."/>
          </xsl:call-template>
          <xsl:if test="position() != last()">, </xsl:if>
        </xsl:for-each>
      </dd>
    </xsl:if>
  </xsl:template>

  <xsl:template name="mir.sherpa.value">
    <xsl:param name="value"/>
    <xsl:variable name="knownValues"
                  select="' submitted accepted published any_repository institutional_repository
                          subject_repository preprint_repository non_commercial_repository
                          non_commercial_institutional_repository non_commercial_subject_repository named_repository
                          any_website authors_homepage institutional_website non_commercial_website
                          academic_social_network named_academic_social_network non_commercial_social_network
                          funder_designated_location this_journal requires_publisher_permission when_required_by_funder
                          when_required_by_law when_required_by_institution when_research_article '"/>
    <xsl:choose>
      <xsl:when test="$value = 'yes'">
        <xsl:value-of select="mcri18n:translate('mir.workflow.sherpa.yes')"/>
      </xsl:when>
      <xsl:when test="$value = 'no'">
        <xsl:value-of select="mcri18n:translate('mir.workflow.sherpa.no')"/>
      </xsl:when>
      <xsl:when test="contains($knownValues, concat(' ', $value, ' '))">
        <xsl:value-of select="mcri18n:translate(concat('mir.workflow.sherpa.value.', $value))"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$value"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>
