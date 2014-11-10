<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mods="http://www.loc.gov/mods/v3"
  exclude-result-prefixes="mods">
  <xsl:include href="layout-utils.xsl" />
  <xsl:template match="/site">
    <xsl:copy>
    <link rel="stylesheet" type="text/css" href="//panzi.github.io/SocialSharePrivacy/stylesheets/jquery.socialshareprivacy.min.css" />

    <script src="http://panzi.github.io/SocialSharePrivacy/javascripts/jquery.socialshareprivacy.min.js" type="text/javascript"></script>
    <script src="http://panzi.github.io/SocialSharePrivacy/javascripts/jquery.socialshareprivacy.min.de.js" type="text/javascript"></script>
    <script type="text/javascript">
      jQuery(document).ready(function($){
        if($('#socialshareprivacy').length > 0){
          $('#socialshareprivacy').socialSharePrivacy({
            "css_path"  : "/lib/socialprivacy/socialshareprivacy/socialshareprivacy.css",
            "lang_path" : "/lib/socialprivacy/socialshareprivacy/lang/",
            "language"  : "de"
          });
        }
      });
    </script>

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

    <div class="row detail_row">
      <div class="col-md-12">
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
        <div class="detail_block">
          <!-- Start: METADATA -->
          <xsl:apply-templates select="div[@id='mir-metadata']" mode="newMetadata" />
          <!-- End: METADATA -->
        </div>
      </div>
      <div class="col-md-4">
        <div class="detail_block">Administrative Metadaten</div>
        <div class="detail_block">
          <h4>Share </h4>
          <div class="row">
            <div class="col-md-7">
              <!-- SocialSharePrivacy BEGIN -->
              <div id="socialshareprivacy"></div>
              <!-- SocialSharePrivacy END -->
            </div>
            <div class="col-md-5">
              <!-- QR-Code BEGIN -->
              <span class="pull-right hidden-xs" rel="tooltip" title="QR-code for easy mobile access to this page.">
                <xsl:variable name="qrSize" select="145"/>
                <img src="{$WebApplicationBaseURL}img/qrcodes/{$qrSize}/{substring-after($RequestURL, $WebApplicationBaseURL)}" style="min-width:{$qrSize}px"
                  alt="QR-code for easy mobile access" />
              </span>
              <!-- QR-Code END -->
            </div>
          </div>
        </div>
        <div class="detail_block">
          <h4>Cite as </h4>
          <!-- Start: CITATION -->
          <xsl:apply-templates select="div[@id='mir-citation']" mode="copyContent" />
          <!-- End: CITATION -->
        </div>
        <div class="detail_block">
          <!-- Start: EXPORT -->
          <xsl:apply-templates select="div[@id='mir-export']" mode="copyContent" />
          <!-- End: EXPORT -->
        </div>

      </div>
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
      <!-- do not print title again -->
      <xsl:apply-templates select=".//div[@id='title_box']/div[@id='title_content']/div/div/table/tr[position() &gt; 1]"
        mode="newMetadata" />
      <xsl:apply-templates select=".//div[@id='category_box']/div[@id='category_content']/table/tr"
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