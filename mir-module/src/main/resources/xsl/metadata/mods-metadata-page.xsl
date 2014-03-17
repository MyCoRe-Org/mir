<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mods="http://www.loc.gov/mods/v3"
  exclude-result-prefixes="mods">
  <xsl:include href="layout-utils.xsl" />
  <xsl:template match="/site">
    <xsl:copy>
      <head>
        <xsl:copy-of select="head/*" />
        <link rel="stylesheet" type="text/css" href="//panzi.github.io/SocialSharePrivacy/stylesheets/jquery.socialshareprivacy.min.css" />
        <style type="text/css">
          <![CDATA[
            ul.social_share_privacy_area.line {
              width: auto;
              display:inline;
            }
            ul.social_share_privacy_area.line div.dummy_btn {
              margin-left: 23px;
            }
            ul.social_share_privacy_area.line span.switch ~ div.dummy_btn {
              margin-left:0;
            }
            ul.social_share_privacy_area.line li {
              float: left;
              clear: left;
              display:inline-block;
            }
          ]]>
        </style>
        <script type="application/x-social-share-privacy-settings">
          <![CDATA[
          {
              "path_prefix": "//panzi.github.io/SocialSharePrivacy/",
              "layout":"line",
              "language": document.documentElement.lang,
              "services":{
                "disqus":{"status":false},
                "flattr":{"status":false},
                "hackernews":{"status":false},
                "pinterest":{"status":false},
                "reddit":{"status":false}
              },
              "order":['facebook','twitter','gplus','stumbleupon','delicious','linkedin','buffer','xing','tumblr','fbshare','mail'],
              "perma_option": true,
              "set_perma_option": function (service_name) {localStorage.setItem('socialSharePrivacy_'+service_name, 'perma_on');},
              "del_perma_option": function (service_name) {localStorage.removeItem('socialSharePrivacy_'+service_name);},
              "get_perma_options": null,
              "get_perma_option": function (service_name) {return localStorage.getItem('socialSharePrivacy_'+service_name) === 'perma_on';}
          }
          ]]>
        </script>
      </head>
      <!-- Start: MESSAGE -->
      <xsl:if test="div[@id='mir-message']">
        <div class="row">
          <div class="col-xs-12">
            <xsl:copy-of select="div[@id='mir-message']/*" />
          </div>
        </div>
      </xsl:if>
      <!-- Start: MESSAGE -->
      <xsl:if test="div[@id='mir-breadcrumb']">
        <div class="row">
          <div class="col-xs-12">
            <xsl:copy-of select="div[@id='mir-breadcrumb']/*" />
          </div>
        </div>
      </xsl:if>
      <!-- End: BREAD-CRUMBS -->
      <div class="row" itemscope="itemscope" itemtype="http://schema.org/ScholarlyArticle">
        <div class="col-md-8">
          <!-- Start: ABSTRACT -->
          <xsl:apply-templates select="div[@id='mir-abstract']" mode="copyContent" />
          <!-- End: ABSTRACT -->
          
          <!-- Start: COLLAPSE -->
          <xsl:if test="div[contains(@id,'mir-collapse-')]">
            <div class="panel-group" id="record_detail">
              <xsl:apply-templates select="div[@id='mir-collapse-preview']" mode="copyContent" />
              <xsl:apply-templates select="div[@id='mir-collapse-files']" mode="copyContent" />
            </div>
          </xsl:if>
          <!-- End: COLLAPSE -->
        </div>
        <div class="col-md-4">

          <div class="well metadata">
            <!-- Start: CITATION -->
            <xsl:apply-templates select="div[@id='mir-metadata']" mode="newMetadata" />
            <!-- End: CITATION -->
          </div>
          <div class="well clearfix">
            <span class="pull-right hidden-xs" rel="tooltip" title="QR-code for easy mobile access to this page.">
              <img src="{$WebApplicationBaseURL}img/qrcodes/{substring-after($RequestURL, $WebApplicationBaseURL)}" width="100"
                alt="QR-code for easy mobile access" />
            </span>
            <h4>Share </h4>
            <!-- SocialSharePrivacy BEGIN -->
            <div data-social-share-privacy="true">
            </div>
            <!-- SocialSharePrivacy END -->
          </div>
          <div class="well">
            <h4>Cite as </h4>
            <!-- Start: CITATION -->
            <xsl:apply-templates select="div[@id='mir-citation']" mode="copyContent" />
            <!-- End: CITATION -->
          </div>
          
          <!-- Start: EXPORT -->
          <xsl:apply-templates select="div[@id='mir-export']" mode="copyContent" />
          <!-- End: EXPORT -->

        </div>
      </div>
      <!-- JAVA Script for bottom -->
      <script type="text/javascript" src="http://panzi.github.io/SocialSharePrivacy/javascripts/jquery.socialshareprivacy.min.js" />
      <xsl:if test="$CurrentLang!='en'">
        <script type="text/javascript" src="http://panzi.github.io/SocialSharePrivacy/javascripts/jquery.socialshareprivacy.min.{$CurrentLang}.js" />
      </xsl:if>
      <script type="text/javascript">
        <![CDATA[
          jQuery(document).ready(function ($) {
           $('*[data-social-share-privacy=true]:not([data-init=true])').socialSharePrivacy().attr('data-init','true');
          });
        ]]>
      </script>
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