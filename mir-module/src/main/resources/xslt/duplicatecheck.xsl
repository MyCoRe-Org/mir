<?xml version="1.0" encoding="UTF-8"?>
<!--
  Renders the possible duplicates found during import (see MIRImportServlet) using the same object
  display as the search result / basket list (mode "basketContent"). The user has to confirm that none
  of the listed objects is a duplicate before the editor is opened.
-->
<xsl:stylesheet version="3.0"
  xmlns:mcri18n="http://www.mycore.de/xslt/i18n"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:import href="xslImport:badges" />

  <xsl:include href="resource:xslt/MyCoReLayout.xsl" />
  <xsl:include href="xslInclude:objectTypes" />

  <xsl:variable name="PageTitle" select="mcri18n:translate('mir.import.dedup.title')" />

  <xsl:template match="/duplicatecheck">
    <div id="duplicate-check">
      <h2>
        <xsl:value-of select="$PageTitle" />
      </h2>
      <p class="lead">
        <xsl:value-of select="mcri18n:translate('mir.import.dedup.intro')" />
      </p>

      <!-- mirror the markup of the search result list (response-mir.xsl) so the same css applies -->
      <div class="row result_body">
        <div class="col-12 result_list">
          <div id="hit_list">
            <xsl:for-each select="object">
              <div id="hit_{position()}"
                class="hit_item {if (position() mod 2 = 1) then 'odd' else 'even'}">
                <div class="row hit_item_head">
                  <div class="col-12">
                    <div class="hit_counter">
                      <xsl:value-of select="position()" />
                    </div>
                  </div>
                </div>
                <div class="row hit_item_body">
                  <div class="col-12">
                    <xsl:apply-templates mode="basketContent"
                      select="document(concat('mcrobject:', @id))/mycoreobject" />
                  </div>
                </div>
              </div>
            </xsl:for-each>
          </div>
          <div class="result_list_end" />
        </div>
      </div>

      <div class="mt-4 d-flex justify-content-end">
        <a class="btn btn-secondary me-2" href="{@cancelURL}">
          <xsl:value-of select="mcri18n:translate('button.cancel')" />
        </a>
        <a class="btn btn-primary" href="{@continueURL}">
          <xsl:value-of select="mcri18n:translate('mir.import.dedup.continue')" />
        </a>
      </div>
    </div>
  </xsl:template>

</xsl:stylesheet>
