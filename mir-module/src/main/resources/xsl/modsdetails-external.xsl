<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xalan="http://xml.apache.org/xalan"
                xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
                xmlns:mcrmods="xalan://org.mycore.mods.classification.MCRMODSClassificationSupport"
                xmlns:basket="xalan://org.mycore.frontend.basket.MCRBasketManager"
                xmlns:mcr="http://www.mycore.org/"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:mods="http://www.loc.gov/mods/v3"
                xmlns:mcrxsl="xalan://org.mycore.common.xml.MCRXMLFunctions"
                xmlns:str="http://exslt.org/strings"
                xmlns:encoder="xalan://java.net.URLEncoder"
                xmlns:acl="xalan://org.mycore.access.MCRAccessManager"
                xmlns:imageware="org.mycore.mir.imageware.MIRImageWarePacker"
                xmlns:pi="xalan://org.mycore.pi.frontend.MCRIdentifierXSLUtils"
                xmlns:piUtil="xalan://org.mycore.pi.frontend.MCRIdentifierXSLUtils"
                exclude-result-prefixes="basket xalan xlink mcr i18n mods mcrmods mcrxsl str encoder acl imageware pi"
                xmlns:ex="http://exslt.org/dates-and-times"
                xmlns:exslt="http://exslt.org/common"
                extension-element-prefixes="ex exslt"
>

  <xsl:param name="MIR.registerDOI" select="''" />
  <xsl:param name="MIR.registerURN" select="'true'" />
  <xsl:param name="template" select="'fixme'" />

  <xsl:param name="MCR.Packaging.Packer.ImageWare.FlagType" />
  <xsl:param name="MIR.ImageWare.Enabled" />
  <xsl:param name="MIR.Workflow.Menu" select="'false'" />

  <xsl:include href="workflow-util.xsl" />
  <xsl:include href="mir-mods-utils.xsl" />

  <!-- do nothing for display parent -->
  <xsl:template match="/mycoreobject" mode="parent" priority="1">
  </xsl:template>

  <xsl:template mode="printDerivatesThumb" match="/mycoreobject[contains(@ID,'_mods_')]" priority="1">
    <xsl:param name="staticURL" />
    <xsl:param name="layout" />
    <xsl:param name="xmltempl" />
    <xsl:param name="modsType" select="'report'" />
    <xsl:variable name="suffix">
      <xsl:if test="string-length($layout)&gt;0">
        <xsl:value-of select="concat('&amp;layout=',$layout)" />
      </xsl:if>
    </xsl:variable>
    <xsl:if test="./structure/derobjects">

      <div class="hit_symbol">
        <img src="{$WebApplicationBaseURL}templates/master/{$template}/IMAGES/icons_liste/big/icon_{$modsType}.png" alt="{$modsType}" title="{$modsType}" />
        <xsl:variable name="embargo" select="metadata/def.modsContainer/modsContainer/mods:mods/mods:accessCondition[@type='embargo']" />
        <xsl:choose>
          <xsl:when test="mcrxsl:isCurrentUserGuestUser() and count($embargo) &gt; 0 and mcrxsl:compare(string($embargo),ex:date-time()) &gt; 0">
            <!-- embargo is active for guest user -->
            <xsl:value-of select="i18n:translate('component.mods.metaData.dictionary.accessCondition.embargo.available',$embargo)" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:for-each select="./structure/derobjects/derobject">
              <xsl:variable name="deriv" select="@xlink:href" />
              <xsl:variable name="derivlink" select="concat('mcrobject:',$deriv)" />
              <xsl:variable name="derivate" select="document($derivlink)" />
              <xsl:variable name="contentTypes" select="document('resource:FileContentTypes.xml')/FileContentTypes" />
              <xsl:variable name="fileType" select="document(concat('ifs:/',@xlink:href,'/'))/mcr_directory/children/child/contentType" />

              <xsl:variable name="derivid" select="$derivate/mycorederivate/@ID" />
              <xsl:variable name="derivlabel" select="$derivate/mycorederivate/@label" />
              <xsl:variable name="derivmain" select="$derivate/mycorederivate/derivate/internals/internal/@maindoc" />
              <xsl:variable name="derivbase" select="concat($ServletsBaseURL,'MCRFileNodeServlet/',$derivid,'/')" />
              <xsl:variable name="derivifs" select="concat($derivbase,$derivmain,$HttpSession)" />
              <xsl:variable name="derivdir" select="concat($derivbase,$HttpSession)" />

              <div class="hit_links">
                <a href="{$derivifs}">
                  <xsl:choose>
                    <xsl:when
                      test="$fileType='pdf' or $fileType='msexcel' or $fileType='xlsx' or $fileType='msword97' or $fileType='docx' or $fileType='html' or $fileType='rtf' or $fileType='txt' or $fileType='xml'"
                    >
                      <img src="{$WebApplicationBaseURL}templates/master/{$template}/IMAGES/icons_liste/download_{$fileType}.png" alt="{$derivmain}" title="{$derivmain}" />
                    </xsl:when>
                    <xsl:otherwise>
                      <img src="{$WebApplicationBaseURL}templates/master/{$template}/IMAGES/icons_liste/download_default.png" alt="{$derivmain}" title="{$derivmain}" />
                    </xsl:otherwise>
                  </xsl:choose>
                </a>
                <a href="{$derivdir}">
                <!-- xsl:value-of select="i18n:translate('buttons.details')" / -->
                  <img src="{$WebApplicationBaseURL}templates/master/{$template}/IMAGES/icons_liste/download_details.png" alt="Details" title="Details"
                    style="padding-bottom:2px;" />
                </a>
              </div>
            </xsl:for-each>
          </xsl:otherwise>
        </xsl:choose>
      </div>
    </xsl:if>
  </xsl:template>

  <xsl:template match="mods:accessCondition" mode="rights_reserved" priority="1">
    <img>
      <xsl:attribute name="src">
        <xsl:value-of select="concat($WebApplicationBaseURL, 'templates/master/', $template , '/IMAGES/copyright.png')" />
      </xsl:attribute>
      <xsl:attribute name="alt">
        <xsl:value-of select="i18n:translate('component.mods.metaData.dictionary.rightsReserved')" />
      </xsl:attribute>
    </img>
  </xsl:template>

  <xsl:template match="children" mode="printChildren" priority="1">
    <xsl:param name="label" select="'enthält'" />

    <!-- the for-each would iterate over <id> with root not beeing /mycoreobject so we save the current node in variable context to access
      needed nodes -->
    <xsl:variable name="context" select="/mycoreobject" />

    <xsl:variable name="children" select="$context/structure/children/child[mcrxsl:isInCategory(@xlink:href,'state:published')]" />
    <xsl:variable name="maxElements" select="20" />
    <xsl:variable name="positionMin">
      <xsl:choose>
        <xsl:when test="count($children) &gt; $maxElements">
          <xsl:value-of select="count($children) - $maxElements + 1" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="0" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <tr>
      <td valign="top" class="metaname">
        <xsl:value-of select="concat($label,':')" />
      </td>
      <td class="metavalue">
        <xsl:if test="$positionMin != 0">
          <p>
            <a href="{$ServletsBaseURL}MCRSearchServlet?parent={$context/@ID}">
              <xsl:value-of select="i18n:translate('component.mods.metaData.displayAll')" />
            </a>
          </p>
        </xsl:if>
        <xsl:choose>
          <xsl:when test="count($children) &gt; 1">
            <!-- display recent $maxElements only -->
            <ul class="document_children">
              <xsl:for-each select="$children[position() &gt;= $positionMin]">
                <li>
                  <xsl:call-template name="objectLink">
                    <xsl:with-param name="obj_id" select="@xlink:href" />
                  </xsl:call-template>
                </li>
              </xsl:for-each>
            </ul>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="objectLink">
              <xsl:with-param name="obj_id" select="$children/@xlink:href" />
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </td>
    </tr>
  </xsl:template>


  <xsl:template match="/mycoreobject" mode="breadCrumb" priority="1">

    <ul class="breadcrumb">
      <li class="first">
        <a href="{$WebApplicationBaseURL}content/main/classifications/mir_genres.xml">
          <xsl:value-of select="i18n:translate('editor.search.mir.genre')" />
        </a>
      </li>
      <xsl:if test="./structure/parents">
        <xsl:variable name="parent_genre">
          <xsl:apply-templates mode="mods-type" select="document(concat('mcrobject:',./structure/parents/parent/@xlink:href))/mycoreobject" />
        </xsl:variable>
        <li>
          <xsl:value-of select="i18n:translate(concat('component.mods.metaData.dictionary.', $parent_genre))" />
          <xsl:text>: </xsl:text>
          <xsl:apply-templates select="./structure/parents">
            <xsl:with-param name="obj_type" select="'this'" />
          </xsl:apply-templates>
          <xsl:apply-templates select="./structure/parents">
            <xsl:with-param name="obj_type" select="'before'" />
          </xsl:apply-templates>
          <xsl:apply-templates select="./structure/parents">
            <xsl:with-param name="obj_type" select="'after'" />
          </xsl:apply-templates>
        </li>
      </xsl:if>

      <xsl:variable name="internal_genre">
        <xsl:apply-templates mode="mods-type" select="." />
      </xsl:variable>
      <li>
        <xsl:value-of select="i18n:translate(concat('component.mods.metaData.dictionary.', $internal_genre))" />
      </li>
      <xsl:if test="./metadata/def.modsContainer/modsContainer/mods:mods/mods:genre[@type='kindof']">
        <li>
          <xsl:apply-templates select="./metadata/def.modsContainer/modsContainer/mods:mods/mods:genre[@type='kindof']" mode="printModsClassInfo" />
        </li>
      </xsl:if>
    </ul>

  </xsl:template>

  <xsl:template priority="2" mode="present" match="/mycoreobject[contains(@ID,'_mods_')]">
    <xsl:variable name="objectBaseURL">
      <xsl:value-of select="concat($WebApplicationBaseURL,'receive/')" />
    </xsl:variable>
    <xsl:variable name="staticURL">
      <xsl:value-of select="concat($objectBaseURL,@ID)" />
    </xsl:variable>

      <!--1***modsContainer************************************* -->
    <xsl:variable name="mods-type">
      <xsl:apply-templates mode="mods-type" select="." />
    </xsl:variable>

    <div id="detail_view" class="well">
      <h3>
        <xsl:apply-templates select="." mode="resulttitle" /><!-- shorten plain text title (without html) -->
      </h3>
      <xsl:choose>
        <xsl:when test="$mods-type='series'">
          <xsl:apply-templates select="." mode="objectActions">
            <xsl:with-param select="'journal'" name="layout" />
            <xsl:with-param select="$mods-type" name="mods-type" />
          </xsl:apply-templates>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="." mode="objectActions">
            <xsl:with-param select="$mods-type" name="layout" />
            <xsl:with-param select="$mods-type" name="mods-type" />
          </xsl:apply-templates>
        </xsl:otherwise>
      </xsl:choose>

      <xsl:choose>
        <!-- xsl:when cases are handled in modsmetadata.xsl -->
        <xsl:when test="$mods-type = 'report'">
          <xsl:apply-templates select="." mode="present.report" />
        </xsl:when>
        <xsl:when test="$mods-type = 'thesis'">
          <xsl:apply-templates select="." mode="present.thesis" />
        </xsl:when>
        <xsl:when test="$mods-type = 'confpro'">
          <xsl:apply-templates select="." mode="present.confpro" />
        </xsl:when>
        <xsl:when test="$mods-type = 'confpub'">
          <xsl:apply-templates select="." mode="present.confpub" />
        </xsl:when>
        <xsl:when test="$mods-type = 'book'">
          <xsl:apply-templates select="." mode="present.book" />
        </xsl:when>
        <xsl:when test="$mods-type = 'chapter'">
          <xsl:apply-templates select="." mode="present.chapter" />
        </xsl:when>
        <xsl:when test="$mods-type = 'journal'">
          <xsl:apply-templates select="." mode="present.journal" />
        </xsl:when>
        <xsl:when test="$mods-type = 'series'">
          <xsl:apply-templates select="." mode="present.series" />
        </xsl:when>
        <xsl:when test="$mods-type = 'article'">
          <xsl:apply-templates select="." mode="present.article" />
        </xsl:when>
        <xsl:when test="$mods-type = 'av'">
          <xsl:apply-templates select="." mode="present.av" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="." mode="present.modsDefaultType">
            <xsl:with-param name="mods-type" select="$mods-type" />
          </xsl:apply-templates>
        </xsl:otherwise>
      </xsl:choose>
      <!--*** Editor Buttons ************************************* -->
      <xsl:if
        test="((./structure/children/child) and not($mods-type='series' or $mods-type='journal' or $mods-type='confpro' or $mods-type='book')) or (./structure/derobjects/derobject)"
      >
        <div id="derivate_box" class="accordion-group">
          <h4 id="derivate_switch" data-target="#derivate_content" data-toggle="collapse" class="accordion-heading">
            <a name="derivate_box"></a>
            <xsl:value-of select="i18n:translate('component.mods.metaData.dictionary.derivatebox')" />
          </h4>
          <div id="derivate_content" class="accordion-body collapse">
            <table class="metaData">
              <!--*** List children per object type ************************************* -->
              <!-- 1.) get a list of objectTypes of all child elements 2.) remove duplicates from this list 3.) for-each objectTyp id list child elements -->
              <xsl:variable name="objectTypes">
                <xsl:for-each select="./structure/children/child/@xlink:href">
                  <id>
                    <xsl:copy-of select="substring-before(substring-after(.,'_'),'_')" />
                  </id>
                </xsl:for-each>
              </xsl:variable>
              <xsl:variable select="xalan:nodeset($objectTypes)/id[not(.=following::id)]" name="unique-ids" />
              <!-- the for-each would iterate over <id> with root not beeing /mycoreobject so we save the current node in variable context to access
                needed nodes -->
              <xsl:variable select="." name="context" />
              <xsl:for-each select="$unique-ids">
                <xsl:variable select="." name="thisObjectType" />
                <xsl:variable name="label">
                  <xsl:choose>
                    <xsl:when test="count($context/structure/children/child[contains(@xlink:href,$thisObjectType)])=1">
                      <xsl:value-of select="i18n:translate(concat('component.',$thisObjectType,'.metaData.[singular]'))" />
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:value-of select="i18n:translate(concat('component.',$thisObjectType,'.metaData.[plural]'))" />
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:variable>
                <xsl:call-template name="printMetaDate">
                  <xsl:with-param select="$context/structure/children/child[contains(@xlink:href, concat('_',$thisObjectType,'_'))]" name="nodes" />
                  <xsl:with-param select="$label" name="label" />
                </xsl:call-template>
              </xsl:for-each>
              <xsl:apply-templates mode="printDerivates" select=".">
                <xsl:with-param select="$staticURL" name="staticURL" />
              </xsl:apply-templates>
            </table>
          </div>
        </div>
      </xsl:if>
      <!--*** Created ************************************* -->
      <div id="system_box" class="accordion-group">
        <div class="accordion-heading">
          <h4 data-target="#system_content" data-toggle="collapse" class="accordion-toggle">
            <xsl:value-of select="i18n:translate('component.mods.metaData.dictionary.systembox')" />
          </h4>
        </div>
        <div id="system_content" class="accordion-body collapse">
          <table class="accordion-inner metaData">
            <xsl:call-template name="printMetaDate">
              <xsl:with-param select="./service/servdates/servdate[@type='createdate']" name="nodes" />
              <xsl:with-param select="i18n:translate('metaData.createdAt')" name="label" />
            </xsl:call-template>
            <!--*** Last Modified ************************************* -->
            <xsl:call-template name="printMetaDate">
              <xsl:with-param select="./service/servdates/servdate[@type='modifydate']" name="nodes" />
              <xsl:with-param select="i18n:translate('metaData.lastChanged')" name="label" />
            </xsl:call-template>
            <!--*** MyCoRe-ID ************************************* -->
            <tr>
              <td class="metaname">
                <xsl:value-of select="concat(i18n:translate('metaData.ID'),':')" />
              </td>
              <td class="metavalue">
                <xsl:value-of select="./@ID" />
              </td>
            </tr>
            <tr>
              <td class="metaname">
                <xsl:value-of select="concat(i18n:translate('metaData.versions'),' :')" />
              </td>
              <td class="metavalue">
                <xsl:apply-templates select="." mode="versioninfo" />
              </td>
            </tr>
          </table>
        </div>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="/mycoreobject[contains(@ID,'_mods_')]" mode="objectActions" priority="2">
    <xsl:param name="id" select="./@ID" />
    <xsl:param name="accessedit" select="key('rights', $id)/@write" />
    <xsl:param name="accessdelete" select="key('rights', $id)/@delete" />
    <xsl:param name="hasURN" select="'false'" />
    <xsl:param name="displayAddDerivate" select="'true'" />
    <xsl:param name="layout" select="'$'" />
    <xsl:param name="mods-type" select="'report'" />
    <xsl:variable name="layoutparam">
      <xsl:if test="$layout != '$'">
        <xsl:value-of select="concat('&amp;layout=',$layout)" />
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="editURL">
      <xsl:call-template name="mods.getObjectEditURL">
        <xsl:with-param name="id" select="$id" />
        <xsl:with-param name="layout" select="$layout" />
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="adminEditURL">
      <xsl:value-of select="actionmapping:getURLforID('update-admin',$id,true())" xmlns:actionmapping="xalan://org.mycore.wfc.actionmapping.MCRURLRetriever" />
    </xsl:variable>
    <xsl:variable name="editURL_allMods">
      <xsl:call-template name="mods.getObjectEditURL">
        <xsl:with-param name="id" select="$id" />
        <xsl:with-param name="layout" select="'all'" />
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="copyURL">
      <xsl:value-of select="actionmapping:getURLforID('create-copy',$id,true())" xmlns:actionmapping="xalan://org.mycore.wfc.actionmapping.MCRURLRetriever" />
    </xsl:variable>
    <xsl:variable name="basketType" select="'objects'" />
    <div class="btn-group d-flex">
      <xsl:choose>
        <xsl:when test="basket:contains($basketType, /mycoreobject/@ID)">
          <a class="btn btn-primary btn-sm w-100"
             href="{$ServletsBaseURL}MCRBasketServlet{$HttpSession}?type={$basketType}&amp;action=remove&amp;redirect={encoder:encode($RequestURL)}&amp;id={/mycoreobject/@ID}">
            <i class="fas fa-minus">
              <xsl:value-of select="' '" />
            </i>
            <xsl:value-of select="concat(' ',i18n:translate('basket.remove'))" />
          </a>
        </xsl:when>
        <xsl:otherwise>
          <a class="btn btn-primary btn-sm w-100"
             href="{$ServletsBaseURL}MCRBasketServlet{$HttpSession}?type={$basketType}&amp;action=add&amp;redirect={encoder:encode($RequestURL)}&amp;id={/mycoreobject/@ID}&amp;uri=mcrobject:{/mycoreobject/@ID}"
          >
            <i class="fas fa-plus">
              <xsl:value-of select="' '" />
            </i>
            <xsl:value-of select="concat(' ',i18n:translate('basket.add'))" />
          </a>
        </xsl:otherwise>
      </xsl:choose>
      <div class="btn-group w-100">
        <a href="#" class="btn btn-secondary btn-sm dropdown-toggle" data-toggle="dropdown">
          <i class="fas fa-cog">
            <xsl:value-of select="' '" />
          </i>
          <xsl:value-of select="concat(' ',i18n:translate('mir.actions'))" />
          <span class="caret"></span>
        </a>
        <ul class="dropdown-menu dropdown-menu-right">
          <xsl:variable name="type" select="substring-before(substring-after($id,'_'),'_')" />
          <xsl:choose>
            <xsl:when test="mcrxsl:isCurrentUserGuestUser()">
              <li>
                <a href="{$ServletsBaseURL}MCRLoginServlet?action=login" class="dropdown-item">
                  <xsl:value-of select="i18n:translate('mir.actions.noaccess')" />
                </a>
              </li>
            </xsl:when>
            <xsl:otherwise>
              <xsl:if test="not($accessedit or $accessdelete)">
                <li>
                  <a href="{$ServletsBaseURL}MCRLoginServlet?action=login" class="dropdown-item">
                    <xsl:value-of select="i18n:translate('mir.actions.norights')" />
                  </a>
                </li>
              </xsl:if>
              <xsl:if test="$accessedit">
                <xsl:choose>
                  <xsl:when test="string-length($editURL) &gt; 0">
                    <li>
                      <a href="{$editURL}" class="dropdown-item">
                        <xsl:value-of select="i18n:translate('object.editObject')" />
                      </a>
                    </li>
                    <xsl:if test="string-length($adminEditURL) &gt; 0">
                      <li>
                        <a href="{$adminEditURL}&amp;id={$id}" class="dropdown-item">
                          <xsl:value-of select="i18n:translate('mir.admineditor')" />
                        </a>
                      </li>
                    </xsl:if>
                    <xsl:if test="normalize-space($MIR.Workflow.Menu)='true'">
                      <xsl:call-template name="listStatusChangeOptions">
                        <xsl:with-param name="class" select="'dropdown-item'"/>
                      </xsl:call-template>
                    </xsl:if>
                    <!-- li> does not work atm
                      <a href="{$WebApplicationBaseURL}editor/change_genre.xed?id={$id}">
                        <xsl:value-of select="i18n:translate('object.editGenre')" />
                      </a>
                    </li -->
                    <xsl:if test="string-length($copyURL) &gt; 0">
                      <li>
                        <a href="{$copyURL}?copyofid={$id}" class="dropdown-item">
                          <xsl:value-of select="i18n:translate('object.copyObject')" />
                        </a>
                      </li>
                    </xsl:if>
                    <xsl:if test="string-length($copyURL) &gt; 0">
                      <li>
                        <a href="{$copyURL}?oldVersion={$id}" class="dropdown-item">
                          <xsl:value-of select="i18n:translate('object.newVersion')" />
                        </a>
                      </li>
                    </xsl:if>
                  </xsl:when>
                  <xsl:otherwise>
                    <li>
                      <xsl:value-of select="i18n:translate('object.locked')" />
                    </li>
                  </xsl:otherwise>
                </xsl:choose>
                <xsl:if test="$displayAddDerivate='true' and not(piUtil:hasManagedPI($id))">
                  <li>
                    <a onclick="javascript: $('.drop-to-object-optional').toggle();" class="dropdown-item">
                      <xsl:value-of select="i18n:translate('mir.upload.addDerivate')" />
                    </a>
                  </li>
                </xsl:if>
                <!-- Register DOI -->
                <xsl:variable name="piServiceInformation" select="piUtil:getPIServiceInformation($id)" />
                <xsl:for-each select="$piServiceInformation">
                  <xsl:if test="@permission='true'">
                    <li>
                    <!-- data-type is just used for translation -->
                      <a href="#" data-type="{@type}"
                         data-mycoreID="{$id}"
                         data-baseURL="{$WebApplicationBaseURL}">
                        <xsl:attribute name="class">
                          <xsl:text>dropdown-item</xsl:text>
                          <xsl:if test="@inscribed='true'">
                            <xsl:text> disabled</xsl:text>
                          </xsl:if>
                        </xsl:attribute>
                        <xsl:if test="@inscribed='false'">
                          <xsl:attribute name="data-register-pi" >
                            <xsl:value-of select="@id" />
                          </xsl:attribute>
                        </xsl:if>
                        <xsl:value-of select="i18n:translate(concat('component.pi.register.',@id))" />
                    </a>
                    </li>
                  </xsl:if>
                </xsl:for-each>
                <!-- Packing with ImageWare Packer -->
                <xsl:if test="imageware:displayPackerButton($id, 'ImageWare')">
                  <li>
                    <a
                      class="dropdown-item"
                      href="{$ServletsBaseURL}MCRPackerServlet?packer=ImageWare&amp;objectId={/mycoreobject/@ID}&amp;redirect={encoder:encode(concat($WebApplicationBaseURL,'receive/',/mycoreobject/@ID,'?XSL.Status.Message=mir.iwstatus.success&amp;XSL.Status.Style=success'))}"
                    >
                      <xsl:value-of select="i18n:translate('object.createImagewareZipPackage')" />
                    </a>
                  </li>
                </xsl:if>
              </xsl:if>
              <xsl:if
                test="$CurrentUser=$MCR.Users.Superuser.UserName or $accessdelete">
                <li>
                  <xsl:choose>
                    <xsl:when test="/mycoreobject/structure/children/child">
                      <xsl:attribute name="class">
                        <xsl:value-of select="'disabled'" />
                      </xsl:attribute>
                      <a href="#" title="{i18n:translate('object.hasChildren')}" class="dropdown-item">
                        <xsl:value-of select="i18n:translate('object.delObject')" />
                      </a>
                    </xsl:when>
                    <xsl:otherwise>
                      <a href="{$ServletsBaseURL}object/delete{$HttpSession}?id={$id}" class="confirm_deletion dropdown-item" data-text="{i18n:translate('mir.confirm.text')}">
                        <xsl:value-of select="i18n:translate('object.delObject')" />
                      </a>
                    </xsl:otherwise>
                  </xsl:choose>
                </li>
              </xsl:if>
              <xsl:if test="string-length($editURL_allMods) &gt; 0">
                <li>
                  <a href="{$editURL_allMods}" class="dropdown-item">
                    <xsl:value-of select="i18n:translate('component.mods.object.editAllModsXML')" />
                  </a>
                </li>
              </xsl:if>
              <xsl:variable name="genreHosts" select="document('classification:metadata:-1:children:mir_genres')" />
              <xsl:variable name="child-layout">
                <xsl:for-each select="$genreHosts//category[contains(label[@xml:lang='x-hosts']/@text, $mods-type)]">
                  <xsl:value-of select="@ID" />
                  <xsl:text>|</xsl:text>
                </xsl:for-each>
              </xsl:variable>
              <!-- xsl:message>
                mods-type:
                <xsl:value-of select="$mods-type" />
                child-layout:
                <xsl:value-of select="$child-layout" />
                accessedit:
                <xsl:value-of select="$accessedit" />
              </xsl:message -->
              <!-- actionmapping.xml must be available for this functionality -->
              <xsl:if test="string-length($child-layout) &gt; 0 and $accessedit and mcrxsl:resourceAvailable('actionmappings.xml')">

                <xsl:variable name="url">
                  <xsl:value-of select="actionmapping:getURLforID('create-child',$id,true())" xmlns:actionmapping="xalan://org.mycore.wfc.actionmapping.MCRURLRetriever" />
                </xsl:variable>

                <xsl:choose>
                  <xsl:when test="not(contains($url, 'editor-dynamic.xed')) and $mods-type != 'series'">
                    <xsl:for-each select="str:tokenize($child-layout,'|')">
                      <li>
                        <a href="{$url}{$HttpSession}?relatedItemId={$id}&amp;relatedItemType=host&amp;genre={.}" class="dropdown-item">
                          <xsl:value-of select="mcrxsl:getDisplayName('mir_genres',.)" />
                        </a>
                      </li>
                    </xsl:for-each>
                  </xsl:when>
                  <xsl:when test="not(contains($url, 'editor-dynamic.xed')) and $mods-type = 'series'">
                    <xsl:for-each select="str:tokenize($child-layout,'|')">
                      <li>
                        <a href="{$url}{$HttpSession}?relatedItemId={$id}&amp;relatedItemType=series&amp;genre={.}" class="dropdown-item">
                          <xsl:value-of select="mcrxsl:getDisplayName('mir_genres',.)" />
                        </a>
                      </li>
                    </xsl:for-each>
                  </xsl:when>
                  <xsl:when test="contains($url, 'editor-dynamic.xed') and $mods-type = 'lecture'">
                    <xsl:for-each select="str:tokenize($child-layout,'|')">
                      <li>
                        <a href="{$url}{$HttpSession}?relatedItemId={$id}&amp;relatedItemType=series&amp;genre={.}&amp;host={$mods-type}" class="dropdown-item">
                          <xsl:value-of select="mcrxsl:getDisplayName('mir_genres',.)" />
                        </a>
                      </li>
                    </xsl:for-each>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:for-each select="str:tokenize($child-layout,'|')">
                      <li>
                        <a href="{$url}{$HttpSession}?relatedItemId={$id}&amp;relatedItemType=host&amp;genre={.}" class="dropdown-item">
                          <xsl:value-of select="mcrxsl:getDisplayName('mir_genres',.)" />
                        </a>
                      </li>
                    </xsl:for-each>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:if>

              <xsl:if test="(key('rights', @ID)/@accKeyEnabled) and (key('rights', @ID)/@write)">
                <li>
                  <a role="menuitem" tabindex="-1"
                     href="{$WebApplicationBaseURL}accesskey/editor.xml?objId={@ID}&amp;url={encoder:encode(string($RequestURL))}"
                     class="dropdown-item"
                  >
                    <xsl:value-of select="i18n:translate('mir.accesskey.manage')" />
                  </a>
                </li>
              </xsl:if>
              <xsl:if test="key('rights', @ID)/@accKeyEnabled and key('rights', @ID)/@hasAccKey and not(mcrxsl:isCurrentUserGuestUser() or $accessedit or $accessdelete)">
                <li>
                  <a role="menuitem" tabindex="-1" href="{$WebApplicationBaseURL}accesskey/set.xed?objId={@ID}&amp;url={encoder:encode(string($RequestURL))}" class="dropdown-item">
                    <xsl:value-of select="i18n:translate('mir.accesskey.setOnUser')" />
                  </a>
                </li>
              </xsl:if>
            </xsl:otherwise>
          </xsl:choose>
        </ul>
      </div>
    </div>
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
            <button type="button" class="btn btn-secondary modal-pi-cancel" data-dismiss="modal">
              <xsl:value-of select="i18n:translate('component.pi.register.modal.abort')" />
            </button>
            <button type="button" class="btn btn-danger" id="modal-pi-add"
                    data-i18n="component.pi.register.">
            </button>
          </div>
        </div>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="derobject" mode="derivateActions">
    <xsl:param name="deriv" />
    <xsl:param name="parentObjID" />

    <xsl:if
      test="(key('rights', $deriv)/@accKeyEnabled and key('rights', $deriv)/@hasAccKey) and not(mcrxsl:isCurrentUserGuestUser() or key('rights', $deriv)/@read or key('rights', $deriv)/@write)"
    >
      <div class="options float-right dropdown">
        <div class="btn-group">
          <a href="#" class="btn btn-secondary dropdown-toggle" data-toggle="dropdown">
            <i class="fas fa-cog"></i>
            <xsl:value-of select="' Aktionen'" />
          </a>
          <ul class="dropdown-menu">
            <li>
              <a role="menuitem" tabindex="-1" href="{$WebApplicationBaseURL}accesskey/set.xed?objId={$deriv}&amp;url={encoder:encode(string($RequestURL))}" class="dropdown-item">
                <xsl:value-of select="i18n:translate('mir.accesskey.setOnUser')" />
              </a>
            </li>
          </ul>
        </div>
      </div>
    </xsl:if>

    <xsl:if test="key('rights', $deriv)/@read">
      <xsl:variable select="concat('mcrobject:',$deriv)" name="derivlink" />
      <xsl:variable select="document($derivlink)" name="derivate" />

      <div class="dropdown float-right options">
        <div class="btn-group">
          <a href="#" class="btn btn-secondary dropdown-toggle" data-toggle="dropdown">
            <i class="fas fa-cog"></i>
            <xsl:value-of select="' Aktionen'" />
          </a>
          <ul class="dropdown-menu dropdown-menu-right">
            <xsl:if test="key('rights', $deriv)/@write">
            <li>
              <a href="{$WebApplicationBaseURL}editor/editor-derivate.xed{$HttpSession}?derivateid={$deriv}" class="option dropdown-item">
                <xsl:value-of select="i18n:translate('component.mods.metaData.options.updateDerivateName')" />
              </a>
            </li>
            </xsl:if>
            <xsl:if test="key('rights', $deriv)/@read">
              <li>
                <a href="{$ServletsBaseURL}MCRZipServlet/{$deriv}" class="option downloadzip dropdown-item">
                  <xsl:value-of select="i18n:translate('component.mods.metaData.options.zip')" />
                </a>
              </li>
            </xsl:if>
            <!--<xsl:if test="key('rights', $deriv)/@write">
              <li>
                <xsl:if test="not(key('rights', $deriv)/@delete)">
                  <xsl:attribute name="class">last</xsl:attribute>
                </xsl:if>
                <xsl:choose>
                    <a href="{$ServletsBaseURL}derivate/update{$HttpSession}?objectid={../../../@ID}&amp;id={$deriv}" class="option">
                      <xsl:value-of select="i18n:translate('component.mods.metaData.options.addFile')" />
                    </a>
                  <xsl:otherwise>
                    <xsl:value-of select="i18n:translate('component.mods.metaData.options.derivateLocked')" />
                  </xsl:otherwise>
                </xsl:choose>
              </li>
            </xsl:if>-->
            <xsl:if test="key('rights', $deriv)/@delete">
              <li class="last">
                <a href="{$ServletsBaseURL}derivate/delete{$HttpSession}?id={$deriv}" class="confirm_deletion option dropdown-item" data-text="{i18n:translate('mir.confirm.derivate.text')}">
                  <xsl:value-of select="i18n:translate('component.mods.metaData.options.delDerivate')" />
                </a>
              </li>
            </xsl:if>
            <xsl:if test="key('rights', $deriv)/@accKeyEnabled and key('rights', $deriv)/@write">
              <li>
                <a role="menuitem" tabindex="-1" class="dropdown-item"
                  href="{$WebApplicationBaseURL}accesskey/editor.xml?objId&amp;url={encoder:encode(string($RequestURL))}"
                >
                  <xsl:value-of select="i18n:translate('mir.accesskey.manage')" />
                </a>
              </li>
            </xsl:if>
          </ul>
        </div>
      </div>
    </xsl:if>
  </xsl:template>

  <xsl:template match="/mycoreobject[contains(@ID,'_mods_')]" mode="basketContent" priority="1">
    <xsl:variable name="objID" select="@ID" />
    <xsl:variable name="mods-type">
      <xsl:apply-templates select="." mode="mods-type" />
    </xsl:variable>

    <xsl:for-each select="./metadata/def.modsContainer/modsContainer/mods:mods">

<!-- document preview -->
      <div class="hit_download_box">
        <xsl:choose>
        <!-- we got a derivate -->
        <xsl:when test="../../../../structure/derobjects">
          <xsl:variable name="identifier" select="../../../../@ID" />
          <xsl:variable name="derivid" select="../../../../structure/derobjects/derobject[1]/@xlink:href" />
          <xsl:variable name="derivate" select="document(concat('mcrobject:',$derivid))" />
          <xsl:variable name="maindoc" select="$derivate/mycorederivate/derivate/internals/internal/@maindoc" />
          <xsl:variable name="contentType" select="document(concat('ifs:/',$derivid))/mcr_directory/children/child[name=$maindoc]/contentType" />
          <xsl:variable name="fileType" select="document('webapp:FileContentTypes.xml')/FileContentTypes/type[mime=$contentType]/@ID" />
          <xsl:choose>
            <xsl:when
                    test="$fileType='msexcel' or $fileType='xlsx' or $fileType='msword97' or $fileType='docx' or $fileType='pptx' or $fileType='msppt' or $fileType='zip'"
            >
              <div class="hit_icon" style="background-image: url('{$WebApplicationBaseURL}images/icons/icon_common.png');" />
              <img class="hit_icon_overlay" src="{$WebApplicationBaseURL}images/svg_icons/download_{$fileType}.svg" />
            </xsl:when>
            <xsl:when test="$fileType='mp3'">
              <div class="hit_icon" style="background-image: url('{$WebApplicationBaseURL}images/icons/icon_common.png');" />
              <img class="hit_icon_overlay" src="{$WebApplicationBaseURL}images/svg_icons/download_audio.svg" />
            </xsl:when>
            <xsl:when test="$fileType='mpg4'">
              <div class="hit_icon" style="background-image: url('{$WebApplicationBaseURL}images/icons/icon_common.png');" />
              <img class="hit_icon_overlay" src="{$WebApplicationBaseURL}images/svg_icons/download_video.svg" />
            </xsl:when>
            <xsl:otherwise>
              <div class="hit_icon {$contentType}"
                   style="background-image:url('{$WebApplicationBaseURL}rsc/thumbnail/{$identifier}/100.jpg')" />
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
          <!-- no derivate -->
          <xsl:otherwise>
            <!-- show default icon -->
            <img class="hit_icon" src="{$WebApplicationBaseURL}images/icons/icon_common_disabled.png" />
          </xsl:otherwise>
        </xsl:choose>
      </div>

<!-- hit type -->
      <div class="hit_tnd_container">
        <div class="hit_tnd_content">
          <div class="hit_type">
            <span class="badge badge-info">
              <xsl:value-of select="mcrxsl:getDisplayName('mir_genres',$mods-type)" />
            </span>
          </div>
          <xsl:if test="mods:originInfo[not(@eventType) or @eventType='publication']/mods:dateIssued or mods:relatedItem/mods:originInfo[not(@eventType) or @eventType='publication']/mods:dateIssued">
            <div class="hit_date">
              <span class="badge badge-primary">
                <xsl:variable name="dateIssued">
                  <xsl:choose>
                    <xsl:when test="mods:originInfo[not(@eventType) or @eventType='publication']/mods:dateIssued"><xsl:apply-templates mode="mods.datePublished" select="mods:originInfo[not(@eventType) or @eventType='publication']/mods:dateIssued" /></xsl:when>
                    <xsl:otherwise><xsl:apply-templates mode="mods.datePublished" select="mods:relatedItem/mods:originInfo[not(@eventType) or @eventType='publication']/mods:dateIssued" /></xsl:otherwise>
                  </xsl:choose>
                </xsl:variable>
                <xsl:variable name="format">
                  <xsl:choose>
                    <xsl:when test="string-length(normalize-space($dateIssued))=4">
                      <xsl:value-of select="i18n:translate('metaData.dateYear')" />
                    </xsl:when>
                    <xsl:when test="string-length(normalize-space($dateIssued))=7">
                      <xsl:value-of select="i18n:translate('metaData.dateYearMonth')" />
                    </xsl:when>
                    <xsl:when test="string-length(normalize-space($dateIssued))=10">
                      <xsl:value-of select="i18n:translate('metaData.dateYearMonthDay')" />
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:value-of select="i18n:translate('metaData.dateTime')" />
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:variable>
                <xsl:call-template name="formatISODate">
                  <xsl:with-param name="date" select="$dateIssued" />
                  <xsl:with-param name="format" select="$format" />
                </xsl:call-template>
              </span>
            </div>
          </xsl:if>
        </div>
      </div>

      <!-- Title, Link to presentation -->
      <h3 class="hit_title">
        <xsl:call-template name="objectLink">
          <xsl:with-param name="obj_id" select="$objID" />
        </xsl:call-template>
      </h3>

<!-- hit author -->
      <div class="hit_author">
        <xsl:for-each select="mods:name[mods:role/mods:roleTerm/text()='aut']">
          <xsl:if test="position()!=1">
            <xsl:value-of select="'/ '" />
          </xsl:if>
          <xsl:apply-templates select="." mode="mirNameLink" />
        </xsl:for-each>
      </div>

<!-- hit parent -->
      <xsl:if test="../../../../structure/parents/parent/@xlink:href">
        <div class="hit_source">
          <span class="label_parent">
            <xsl:value-of select="'aus: '" />
          </span>
          <xsl:call-template name="objectLink">
            <xsl:with-param name="obj_id" select="../../../../structure/parents/parent/@xlink:href" />
          </xsl:call-template>
        </div>
      </xsl:if>

<!-- hit abstract -->
      <div class="hit_abstract">
        <xsl:if test="mods:abstract[not(@altFormat)]">
          <xsl:value-of select="mcrxsl:shortenText(mods:abstract[not(@altFormat)],300)" />
        </xsl:if>
      </div>

<!-- hit publisher -->
      <xsl:if test="//mods:originInfo[not(@eventType) or @eventType='publication']/mods:publisher">
        <div class="hit_pub_name">
          <span class="label_publisher">
            <xsl:value-of select="concat(i18n:translate('component.mods.metaData.dictionary.published'),': ')" />
          </span>
          <xsl:value-of select="//mods:originInfo/mods:publisher" />
        </div>
      </xsl:if>

      <xsl:if test="//mods:originInfo[@eventType='creation']/mods:publisher">
        <div class="hit_pub_name">
          <span class="label_publisher">
            <xsl:value-of select="concat(i18n:translate('component.mods.metaData.dictionary.publisher.creation'),': ')" />
          </span>
          <xsl:value-of select="//mods:originInfo[@eventType='creation']/mods:publisher" />
        </div>
      </xsl:if>
    </xsl:for-each>

  </xsl:template>

  <!--  info:eu-repo/grantAgreement/EC/FP7/324387/EU/Risk Management Software System for SMEs in the Construction Industry/RIMACON -->
  <!--   Projektname: Risk Management Software System for SMEs in the Const -->
  <!--   Projekt-Akronym: RIMACON -->
  <!--   Grant-ID: 324387 -->
  <!--   Programm-ID: FP7 -->
  <!--   Organisations-ID: EC -->
  <xsl:template match="mods:identifier[@type='open-aire']" mode="openaire">
    <xsl:variable name="project-details">
      <xsl:call-template name="Tokenizer"><!-- use split function from mycore-base/coreFunctions.xsl -->
        <xsl:with-param name="string" select="." />
        <xsl:with-param name="delimiter" select="'/'" />
      </xsl:call-template>
    </xsl:variable>

    <xsl:if test="string-length(exslt:node-set($project-details)/token[position() = 7]) &gt; 0">
      <tr>
        <td valign="top" class="metaname">
          <xsl:value-of select="i18n:translate('mir.project.name')" />
        </td>
        <td class="metavalue">
          <xsl:value-of select="exslt:node-set($project-details)/token[position() = 7]" />
        </td>
      </tr>
    </xsl:if>
    <xsl:if test="string-length(exslt:node-set($project-details)/token[position() = 8]) &gt; 0">
      <tr>
        <td valign="top" class="metaname">
          <xsl:value-of select="i18n:translate('mir.project.acronym')" />
        </td>
        <td class="metavalue">
          <xsl:value-of select="exslt:node-set($project-details)/token[position() = 8]" />
        </td>
      </tr>
    </xsl:if>
    <xsl:if test="string-length(exslt:node-set($project-details)/token[position() = 5]) &gt; 0">
      <tr>
        <td valign="top" class="metaname">
          <xsl:value-of select="concat(i18n:translate('mir.project.grantID'),':')" />
        </td>
        <td class="metavalue">
          <xsl:value-of select="exslt:node-set($project-details)/token[position() = 5]" />
        </td>
      </tr>
    </xsl:if>
    <xsl:if test="string-length(exslt:node-set($project-details)/token[position() = 4]) &gt; 0">
      <tr>
        <td valign="top" class="metaname">
          <xsl:value-of select="concat(i18n:translate('mir.project.sponsor.programmID'),':')" />
        </td>
        <td class="metavalue">
          <xsl:value-of select="exslt:node-set($project-details)/token[position() = 4]" />
        </td>
      </tr>
    </xsl:if>
    <xsl:if test="string-length(exslt:node-set($project-details)/token[position() = 3]) &gt; 0">
      <tr>
        <td valign="top" class="metaname">
          <xsl:value-of select="concat(i18n:translate('mir.project.sponsor.organisationID'),':')" />
        </td>
        <td class="metavalue">
          <xsl:value-of select="exslt:node-set($project-details)/token[position() = 3]" />
        </td>
      </tr>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
