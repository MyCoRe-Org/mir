<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mods="http://www.loc.gov/mods/v3" xmlns:mcrxsl="xalan://org.mycore.common.xml.MCRXMLFunctions"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation" exclude-result-prefixes="mods mcrxsl i18n"
>
  <xsl:include href="layout-utils.xsl" />

  <xsl:template match="/site">
    <xsl:copy>
      <head>
        <xsl:apply-templates select="citation_meta" mode="copyContent" />
        <link href="{$WebApplicationBaseURL}assets/jquery/plugins/shariff/shariff.min.css" rel="stylesheet" />
        <script type="text/javascript" src="{$WebApplicationBaseURL}assets/jquery/plugins/dotdotdot/jquery.dotdotdot.min.js" />
      </head>

      <xsl:if test="div[@id='mir-breadcrumb']">
        <breadcrumb>
          <xsl:copy-of select="div[@id='mir-breadcrumb']/*" />
        </breadcrumb>
      </xsl:if>

      <xsl:if test="div[@id='search_browsing']">
        <div class="row detail_row">
          <div class="col-md-12">
            <div class="detail_block text-center">
              <span id="pagination_label">gefundende Dokumente</span>
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

      <div class="row detail_row" itemscope="itemscope" itemtype="http://schema.org/ScholarlyArticle">

        <div id="head_col" class="col-xs-12">
          <div class="row">
            <div class="col-md-4 col-md-push-8">
              <div class="pull-right">
                <!-- Start: EDIT -->
                <xsl:apply-templates select="div[@id='mir-edit']" mode="copyContent" />
                <!-- End: EDIT -->
              </div>
            </div>
            <div class="col-md-8 col-md-pull-4">
              <xsl:apply-templates select="div[@id='mir-abstract-badges']" mode="copyContent" />
            </div>
          </div>
          <div class="row">
            <div id="headline" class="col-xs-12 col-md-8">
              <xsl:apply-templates select="div[@id='mir-abstract-title']" mode="copyContent" />
            </div>
          </div>
        </div>

        <div id="main_col" class="col-md-8">
          <div class="detail_block">
          <!-- Start: ABSTRACT -->
            <xsl:apply-templates select="div[@id='mir-abstract-plus']" mode="copyContent" />
          <!-- End: ABSTRACT -->
          </div>

          <!-- viewer -->
          <xsl:if test="div[@id = 'mir-viewer']">
            <xsl:apply-templates select="div[@id='mir-viewer']" mode="copyContent" />
          </xsl:if>
          <!-- player -->
          <xsl:if test="div[@id = 'mir-player']">
            <xsl:apply-templates select="div[@id='mir-player']" mode="copyContent" />
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
            </div>
          </xsl:if>

<!-- end: left column -->
        </div>

<!-- right column -->
        <div id="aux_col" class="col-md-4">

<!-- cites -->
          <xsl:if test="div[@id='mir-citation']">
            <div class="panel panel-default">
              <div class="panel-heading">
                <h3 class="panel-title">Zitieren</h3>
              </div>
              <div class="panel-body">
                <!-- Start: CITATION -->
                <xsl:apply-templates select="div[@id='mir-citation']" mode="copyContent" />
                <!-- End: CITATION -->
              </div>
            </div>
          </xsl:if>
<!-- rights -->
          <xsl:if test="div[@id='mir-access-rights']">
            <div id="mir_access_rights_panel" class="panel panel-default">
              <div class="panel-heading">
                <h3 class="panel-title">Rechte</h3>
              </div>
              <div class="panel-body">
                <!-- Start: CITATION -->
                <xsl:apply-templates select="div[@id='mir-access-rights']" mode="copyContent" />
                <!-- End: CITATION -->
              </div>
            </div>
          </xsl:if>
<!-- export -->
          <div id="mir_export_panel" class="panel panel-default">
            <div class="panel-heading">
              <h3 class="panel-title">Export</h3>
            </div>
            <div class="panel-body">
                <!-- Start: EXPORT -->
              <xsl:apply-templates select="div[@id='mir-export']" mode="copyContent" />
                <!-- End: EXPORT -->
            </div>
          </div>
<!-- system -->
          <xsl:if test="not(mcrxsl:isCurrentUserGuestUser())">
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
            </div>
          </xsl:if>

<!-- end: right column -->
        </div>

<!--  end: detail row -->
      </div>
      <script src="{$WebApplicationBaseURL}assets/jquery/plugins/shariff/shariff.min.js"></script>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="citation_meta" mode="copyContent">
    <xsl:message>
      <xsl:value-of select="'Handling citation meta tags'" />
    </xsl:message>
    <xsl:copy-of select="./*" />
  </xsl:template>

  <xsl:template match="div" mode="copyContent">
    <xsl:message>
      <xsl:value-of select="concat('Handling div: ',@id)" />
    </xsl:message>
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