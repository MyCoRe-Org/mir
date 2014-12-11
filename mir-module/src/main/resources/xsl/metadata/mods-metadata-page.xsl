<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mods="http://www.loc.gov/mods/v3"
  exclude-result-prefixes="mods">
  <xsl:include href="layout-utils.xsl" />

  <xsl:template match="/site">
    <xsl:copy>
      <head>
        <script type="text/javascript" src="{$WebApplicationBaseURL}js/socialprivacy/jquery.socialshareprivacy.js"></script>
        <script type="text/javascript">
          jQuery(document).ready(function($){
            if($('#socialshareprivacy').length > 0){
              $('#socialshareprivacy').socialSharePrivacy({
                "css_path"  : "<xsl:value-of select="concat($WebApplicationBaseURL, 'js/socialprivacy/socialshareprivacy/socialshareprivacy.css')" />",
                "lang_path" : "<xsl:value-of select="concat($WebApplicationBaseURL, 'js/socialprivacy/socialshareprivacy/lang/')" />",
                "language"  : "de"
              });
            }
          });
        </script>
        <link href="{$WebApplicationBaseURL}js/shariff/shariff.min.css" rel="stylesheet" />
      </head>

      <div class="row detail_row">
        <div class="col-md-12">
          <div class="detail_block text-center">
            <!-- Start: PAGINATION -->
            <xsl:apply-templates select="div[@id='search_options']" mode="copyContent" />
            <!-- End: PAGINATION -->
          </div>
        </div>
      </div>

      <!-- Start: MESSAGE -->
      <xsl:if test="div[@id='mir-message']">
        <div class="row detail_row">
          <div class="col-md-12">
            <xsl:copy-of select="div[@id='mir-message']/*" />
          </div>
        </div>
      </xsl:if>
      <!-- End: MESSAGE -->

      <div class="row detail_row bread_plus">
        <div class="col-xs-12">
          <!-- Start: BREAD-CRUMBS -->
          <xsl:if test="div[@id='mir-breadcrumb']">
            <xsl:copy-of select="div[@id='mir-breadcrumb']/*" />
          </xsl:if>
          <!-- End: BREAD-CRUMBS -->
          <div class="detail_block text-right">
            <!-- Start: EDIT -->
            <xsl:apply-templates select="div[@id='mir-edit']" mode="copyContent" />
            <!-- End: EDIT -->
          </div>
        </div>
      </div>

      <div class="row detail_row" itemscope="itemscope" itemtype="http://schema.org/ScholarlyArticle">
        <div class="col-md-8">
          <div class="detail_block">

          <!-- Start: ABSTRACT -->
          <xsl:apply-templates select="div[@id='mir-abstract']" mode="copyContent" />
          <!-- End: ABSTRACT -->

          </div>
          <div class="detail_block">
            <!-- Start: COLLAPSE -->
            <xsl:if test="div[contains(@id,'mir-collapse-')]">
              <div class="panel-group" id="record_detail">
                <xsl:apply-templates select="div[@id='mir-collapse-preview']" mode="copyContent" />
                <xsl:apply-templates select="div[@id='mir-collapse-files']" mode="copyContent" />
              </div>
            </xsl:if>
            <!-- End: COLLAPSE -->
          </div>

<!-- metadata -->
          <div class="panel panel-default mir_metadata">
            <div class="panel-heading">
              <h3 class="panel-title">Einordnung</h3>
            </div>
            <div class="panel-body">
            <!-- Start: METADATA -->
            <xsl:apply-templates select="div[@id='mir-metadata']" mode="newMetadata" />
            <!-- End: METADATA -->
            </div>
          </div>

<!-- end: left column -->
        </div>

<!-- right column -->
        <div class="col-md-4">
<!-- social -->
            <div class="panel panel-default">
              <div class="panel-heading">
                <h3 class="panel-title">Teilen</h3>
              </div>
              <div class="panel-body">
                <!-- Start: SHARE -->
                <xsl:apply-templates select="div[@id='mir-share']" mode="copyContent" />
                <!-- End: SHARE -->
              </div>
            </div>
<!-- cites -->
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
<!-- export -->
            <div class="panel panel-default">
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
            <div class="panel panel-default system">
              <div class="panel-heading">
                <h3 class="panel-title">Systeminformationen</h3>
              </div>
              <div class="panel-body">
                <!-- Start: ADMINMETADATA -->
                <xsl:apply-templates select="div[@id='mir-admindata']" mode="newMetadata" />
                <!-- End: ADMINMETADATA -->
              </div>
            </div>

<!-- end: right column -->
        </div>

<!--  end: detail row -->
      </div>
    </xsl:copy>
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
      <xsl:apply-templates select=".//div[@id='system_box']/div[@id='system_content']/table/tr"
        mode="newMetadata" />
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