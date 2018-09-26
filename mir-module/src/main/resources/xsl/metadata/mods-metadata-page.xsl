<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mods="http://www.loc.gov/mods/v3" xmlns:mcrxsl="xalan://org.mycore.common.xml.MCRXMLFunctions"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation" xmlns:ex="http://exslt.org/dates-and-times" exclude-result-prefixes="mods mcrxsl i18n ex"
>
  <xsl:include href="layout-utils.xsl" />

  <xsl:param name="MIR.OAS" select="'hide'" />

  <xsl:template match="/site">
    <xsl:copy>
      <xsl:copy-of select="@*" />
      <head>
        <xsl:apply-templates select="citation_meta" mode="copyContent" />
        <link href="{$WebApplicationBaseURL}mir-layout/assets/jquery/plugins/shariff/shariff.complete.css" rel="stylesheet" />
      </head>

      <xsl:if test="div[@id='mir-breadcrumb']">
        <breadcrumb>
          <xsl:copy-of select="div[@id='mir-breadcrumb']/*" />
        </breadcrumb>
      </xsl:if>

      <xsl:if test="div[@id='search_browsing']">
        <div class="row detail_row" id="mir-search_browsing">
          <div class="col-md-8">
            <div class="detail_block text-center">
              <!-- span id="pagination_label">gefundende Dokumente</span -->
              <br />
              <!-- Start: PAGINATION -->
              <xsl:apply-templates select="div[@id='search_browsing']" mode="copyContent" />
              <!-- End: PAGINATION -->
            </div>
          </div>
        </div>
      </xsl:if>

      <!-- Start: MESSAGE -->
      <xsl:if test="div[@id='mir-message']">
        <div class="row detail_row">
          <div class="col-md-12">
            <xsl:copy-of select="div[@id='mir-message']/*" />
          </div>
        </div>
      </xsl:if>
      <!-- End: MESSAGE -->

      <div class="row detail_row">

        <div id="head_col" class="col-xs-12">
          <div class="row">
            <div id="aux_col_actions" class="col-xs-12 col-sm-4 col-sm-push-8 col-md-4 col-md-push-8">
              <div class="pull-right">
                <!-- Start: EDIT -->
                <xsl:apply-templates select="div[@id='mir-edit']" mode="copyContent" />
                <!-- End: EDIT -->
              </div>
            </div>
            <div class="col-xs-12 col-sm-8 col-sm-pull-4 col-md-8 col-md-pull-4">
              <xsl:apply-templates select="div[@id='mir-abstract-badges']" mode="copyContent" />
            </div>
          </div>
        </div>

        <div id="main_col" class="col-xs-12 col-sm-8">
          <div id="headline">
            <xsl:apply-templates select="div[@id='mir-abstract-title']" mode="copyContent" />
          </div>
          <div class="detail_block">
          <!-- Start: ABSTRACT -->
            <xsl:apply-templates select="div[@id='mir-abstract-plus']" mode="copyContent" />
          <!-- End: ABSTRACT -->
          </div>
          <!-- fileupload -->
          <xsl:if test="div[contains(@id,'mir-file-upload')]">
            <xsl:apply-templates select="div[@id='mir-file-upload']" mode="copyContent" />
          </xsl:if>
          <!-- player -->
          <xsl:if test="div[@id = 'mir-player']">
            <xsl:apply-templates select="div[@id='mir-player']" mode="copyContent" />
          </xsl:if>
          <!-- viewer -->
          <xsl:if test="div[@id = 'mir-viewer']">
            <xsl:apply-templates select="div[@id='mir-viewer']" mode="copyContent" />
          </xsl:if>
          <!-- files -->
          <xsl:if test="div[contains(@id,'mir-collapse-')]">
            <div class="detail_block">
              <div class="" id="record_detail">
                <xsl:apply-templates select="div[@id='mir-collapse-files']" mode="copyContent" />
              </div>
            </div>
          </xsl:if>

<!-- metadata -->
          <xsl:if test="div[contains(@id,'mir-metadata')]/table[@class='mir-metadata']/tr">
            <div class="mir_metadata">
              <h3>
                <xsl:value-of select="i18n:translate('component.mods.metaData.dictionary.categorybox')" />
              </h3>
            <!-- Start: METADATA -->
              <xsl:apply-templates select="div[@id='mir-metadata']" mode="newMetadata" />
            <!-- End: METADATA -->
              <xsl:if test="div[contains(@id,'mir-metadata')]/table[@class='mir-metadata']/tr/td/div[contains(@class,'openstreetmap-container')]">
                <link rel="stylesheet" type="text/css" href="{$WebApplicationBaseURL}assets/openlayers/ol.css" />
                <script type="text/javascript" src="{$WebApplicationBaseURL}assets/openlayers/ol.js" />
                <script type="text/javascript" src="{$WebApplicationBaseURL}js/mir/geo-coords.min.js"></script>
              </xsl:if>
            </div>
          </xsl:if>

<!-- end: left column -->
        </div>

<!-- right column -->
        <div id="aux_col" class="col-xs-12 col-sm-4">

<!-- cites -->
          <xsl:if test="div[@id='mir-citation']">
            <div class="panel panel-default">
              <div class="panel-heading">
                <h3 class="panel-title">
                  <xsl:value-of select="i18n:translate('metaData.quote')" /></h3>
              </div>
              <div class="panel-body">
                <!-- Start: CITATION -->
                <xsl:apply-templates select="div[@id='mir-citation']" mode="copyContent" />
                <!-- End: CITATION -->
              </div>
            </div>
          </xsl:if>
<!-- OAS statistics -->
          <xsl:if test="$MIR.OAS = 'show' and div[@id='mir-oastatistics']">
            <div class="panel panel-default">
              <div class="panel-heading">
                <h3 class="panel-title">
                  <xsl:value-of select="i18n:translate('mir.oas.panelheading')" />
                </h3>
              </div>
              <div class="panel-body" id="mir_oas">
                <xsl:apply-templates select="div[@id='mir-oastatistics']" mode="copyContent" />
              </div>
            </div>
          </xsl:if>
<!-- rights -->
          <xsl:if test="div[@id='mir-access-rights']">
            <div id="mir_access_rights_panel" class="panel panel-default">
              <div class="panel-heading">
                <h3 class="panel-title"><xsl:value-of select="i18n:translate('metaData.rights')" /></h3>
              </div>
              <div class="panel-body">
                <!-- Start: CITATION -->
                <xsl:apply-templates select="div[@id='mir-access-rights']" mode="copyContent" />
                <!-- End: CITATION -->
              </div>
            </div>
          </xsl:if>
<!-- export -->
          <xsl:if test="div[@id='mir-export']">
            <div id="mir_export_panel" class="panel panel-default">
              <div class="panel-heading">
                <h3 class="panel-title"><xsl:value-of select="i18n:translate('metaData.export')" /></h3>
              </div>
              <div class="panel-body">
                  <!-- Start: EXPORT -->
                <xsl:apply-templates select="div[@id='mir-export']" mode="copyContent" />
                  <!-- End: EXPORT -->
              </div>
            </div>
          </xsl:if>
<!-- system -->
          <xsl:if test="not(mcrxsl:isCurrentUserGuestUser()) and @read">
            <div id="mir_admindata_panel" class="panel panel-default system">
              <div class="panel-heading">
                <h3 class="panel-title">
                  <xsl:value-of select="i18n:translate('component.mods.metaData.dictionary.systembox')" />
                </h3>
              </div>
              <div class="panel-body">
                <!-- Start: ADMINMETADATA -->
                <xsl:apply-templates select="div[@id='mir-admindata']" mode="newMetadata" />
                <!-- End: ADMINMETADATA -->
              </div>
              <div class="modal fade" id="historyModal" tabindex="-1" role="dialog" aria-labelledby="modal frame" aria-hidden="true">
                <div class="modal-dialog" style="width: 930px">
                  <div class="modal-content">
                    <div class="modal-header">
                      <button type="button" class="close modalFrame-cancel" data-dismiss="modal" aria-label="Close">
                        <i class="fa fa-times" aria-hidden="true"></i>
                      </button>
                      <h4 class="modal-title" id="modalFrame-title">
                        <xsl:value-of select="i18n:translate('metadata.versionInfo.label')" />
                      </h4>
                    </div>
                    <div id="modalFrame-body" class="modal-body" style="max-height: 560px; overflow: auto">
                      <xsl:apply-templates select="div[@id='mir-historydata']" mode="copyContent" />
                    </div>
                    <div class="modal-footer" style="clear: both">
                      <button id="modalFrame-cancel" type="button" class="btn btn-danger" data-dismiss="modal">
                        <xsl:value-of select="i18n:translate('button.cancel')" />
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </xsl:if>

<!-- end: right column -->
        </div>

        <xsl:copy-of select="document(concat('xslTransform:schemaOrg:mcrobject:', @ID))" />
<!--  end: detail row -->
      </div>
      <script src="{$WebApplicationBaseURL}mir-layout/assets/jquery/plugins/shariff/shariff.min.js"></script>
      <script src="{$WebApplicationBaseURL}assets/moment/min/moment.min.js"></script>
      <script src="{$WebApplicationBaseURL}assets/handlebars/handlebars.min.js"></script>
      <script src="{$WebApplicationBaseURL}js/mir/derivate-fileList.min.js"></script>
      <link rel="stylesheet" href="{$WebApplicationBaseURL}rsc/stat/{@ID}.css"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="citation_meta" mode="copyContent">
    <xsl:copy-of select="./*" />
  </xsl:template>

  <xsl:template match="div" mode="copyContent">
    <xsl:copy-of select="./*" />
  </xsl:template>

  <xsl:template match="div[@id='mir-metadata']" mode="newMetadata">
    <dl>
      <xsl:apply-templates select="table[@class='mir-metadata']/tr" mode="newMetadata" />
    </dl>
  </xsl:template>
  <xsl:template match="div[@id='mir-admindata']" mode="newMetadata">
    <dl>
      <xsl:apply-templates select=".//div[@id='system_box']/div[@id='system_content']/table/tr" mode="newMetadata" />
    </dl>
  </xsl:template>
  <xsl:template match="td[@class='metaname']" mode="newMetadata" priority="2">
    <dt>
      <xsl:copy-of select="node()|*" />
    </dt>
  </xsl:template>
  <xsl:template match="td[@class='metavalue']" mode="newMetadata" priority="2">
    <dd>
      <xsl:copy-of select="node()|*" />
    </dd>
  </xsl:template>

</xsl:stylesheet>
