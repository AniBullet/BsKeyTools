# Importing libraries
import PySide6
import json
import os
import pymxs
import time
import uuid
import webbrowser
from PySide6 import QtGui, QtCore, QtWidgets
from PySide6.QtCore import QFile, Qt
from PySide6.QtGui import QIcon, QColor
from PySide6.QtUiTools import QUiLoader
from PySide6.QtWidgets import QMainWindow, QGridLayout, QWidget, QFileDialog, QMessageBox, QStyle
from pymxs import runtime as mxs
from qtmax import GetQMaxMainWindow


# Define Dialog Window
class PostureDialog(QMainWindow):
    def __init__(self, parent=None):
        super(PostureDialog, self).__init__(parent)

        self.setWindowFlags(QtCore.Qt.WindowType.Window)

        # Define Global Variables / Icons and Logo
        self.define_variables()

        self.dir = mxs.getDir(mxs.name('publicExchangeStoreInstallPath'))

        # Define icons (using Qt standard icons)
        self.init_standard_icons()

        # Set Dialog Properties
        self.setWindowTitle('Posture - v1.3.1 beta')
        self.setWindowIcon(self.posture_icon)
        self.resize(700, 480)

        # Define User-Interface
        self.init_UI()

        # Update Tree
        self.start()

        # Define Signals
        self.signals()

    def create_text_icon(self, text, size=24):
        """创建文字图标"""
        pixmap = QtGui.QPixmap(size, size)
        pixmap.fill(Qt.transparent)
        painter = QtGui.QPainter(pixmap)
        painter.setPen(QtGui.QColor(255, 255, 255))
        painter.setFont(QtGui.QFont("Arial", int(size * 0.6)))
        painter.drawText(pixmap.rect(), Qt.AlignCenter, text)
        painter.end()
        return QtGui.QIcon(pixmap)
    
    def init_standard_icons(self):
        # Define Icons using emoji and text for better recognition
        self.save_icon = self.create_text_icon("💾")
        self.folder_icon = self.create_text_icon("📁")
        self.geometry_icon = self.create_text_icon("📦")
        self.shape_icon = self.create_text_icon("🔺")
        self.camera_icon = self.create_text_icon("📷")
        self.helper_icon = self.create_text_icon("🛠️")
        self.light_icon = self.create_text_icon("💡")
        self.spacewarp_icon = self.create_text_icon("🌀")
        self.profile_icon = self.create_text_icon("👤")
        self.posture_icon = self.create_text_icon("🎭")
        self.instagram_icon = self.create_text_icon("📷")
        self.cancel_icon = self.create_text_icon("❌")
        self.cgcenter_icon = self.create_text_icon("🏢")
        self.telegram_icon = self.create_text_icon("📱")
        self.gumroad_icon = self.create_text_icon("🛒")
        self.youtube_icon = self.create_text_icon("📺")
        self.facebook_icon = self.create_text_icon("👥")
        self.artstation_icon = self.create_text_icon("🎨")
        self.twitter_icon = self.create_text_icon("🐦")


    # Write Data To File
    def write_data(self):
        mxs.escapeEnable = False

        try:
            fname = list(QFileDialog.getSaveFileName(self, 'Save file', filter="*.json"))

            if fname:

                with open(fname[0], 'w') as save_file:
                    json.dump(self.global_data, save_file, indent=2)
                    save_file.close()

                    self.ui.pte_reports.appendHtml(
                        f'''<p><span style="color:#77e73a">#Posture data saved to <strong>{fname[0]}</strong></span></p>''')

            else:
                self.ui.pte_reports.appendHtml(
                    f'''<p><span style="color:red"> <strong>Error:</strong> </span></p>''')
                self.ui.pte_reports.appendHtml(
                    f'''<p><span style="color:orange">Importing was Incomplete.</span></p>''')

        except:
            self.ui.pte_reports.appendHtml(
                f'''<p><span style="color:red"> <strong>Error:</strong> </span></p>''')
            self.ui.pte_reports.appendHtml(
                f'''<p><span style="color:orange">Exporting was Incomplete.</span></p>''')
        mxs.escapeEnable = True

    # Load Data From File
    def load_data(self):
        mxs.escapeEnable = False
        try:
            fname = list(QFileDialog.getOpenFileName(self, 'Open file', filter="*.json"))

            if fname:

                with open(fname[0], 'r') as load_file:
                    loaded_data = json.load(load_file)
                    self.global_data = loaded_data
                    load_file.close()
                    self.update_profile_list()

                    self.ui.pte_reports.appendHtml(
                        f'''<p><span style="color:#77e73a"><strong>{fname[0]}</strong> loaded to #Posture.</span></p>''')

            else:
                self.ui.pte_reports.appendHtml(
                    f'''<p><span style="color:red"> <strong>Error:</strong> </span></p>''')
                self.ui.pte_reports.appendHtml(
                    f'''<p><span style="color:orange">Importing was Incomplete.</span></p>''')

        except:
            self.ui.pte_reports.appendHtml(
                f'''<p><span style="color:red"> <strong>Error:</strong> </span></p>''')
            self.ui.pte_reports.appendHtml(
                f'''<p><span style="color:orange">Importing was Incomplete.</span></p>''')

        mxs.escapeEnable = True

    # Jobs On First Execute
    def start(self):
        self.ui.pte_reports.appendHtml(
            f'''<p><span style="color:white" style="font-size:16px"> Welcome to #Posture v1.3.1</span></p>''')

        self.ui.le_profile_rename.setVisible(False)
        self.ui.btn_rename_cancel.setVisible(False)

        self.global_data = {}
        self.ui.btn_load_file.setIcon(self.folder_icon)
        self.ui.btn_save_file.setIcon(self.save_icon)
        self.ui.btn_rename_cancel.setIcon(self.cancel_icon)
        self.ui.instagram.setIcon(self.instagram_icon)
        self.ui.cgcenter.setIcon(self.cgcenter_icon)

        self.ui.artstation.setIcon(self.artstation_icon)
        self.ui.facebook.setIcon(self.facebook_icon)
        self.ui.telegram.setIcon(self.telegram_icon)
        self.ui.gumroad.setIcon(self.gumroad_icon)
        self.ui.twitter.setIcon(self.twitter_icon)
        self.ui.youtube.setIcon(self.youtube_icon)

    # Update Profile list when data loaded
    def update_profile_list(self):

        # Define MAximum Value Of ProgressBar
        if len(self.global_data) != 0:
            self.ui.progresss.setMaximum(len(self.global_data))

        self.ui.lw_profiles.clear()

        index = 0
        for i in self.global_data:
            self.ui.lw_profiles.addItem(f"{i}")
            self.ui.lw_profiles.item(index).setIcon(self.profile_icon)
            index += 1
            self.ui.progresss.setValue(index + 1)

        self.ui.progresss.setValue(0)

    # Def Signals
    def signals(self):
        self.ui.btn_add.clicked.connect(self.adding_nodes)
        self.ui.btn_save.clicked.connect(self.save_profile)
        self.ui.btn_clear.clicked.connect(self.clear_selection_and_node_list)
        self.ui.btn_load.clicked.connect(self.apply_data)
        self.ui.btn_save_file.clicked.connect(self.write_data)
        self.ui.btn_load_file.clicked.connect(self.load_data)
        self.ui.btn_delete.clicked.connect(self.delete_profile)
        self.ui.btn_rename.clicked.connect(self.rename_profile)
        self.ui.le_profile_rename.returnPressed.connect(self.rename)

        self.ui.btn_rename_cancel.clicked.connect(self.cancel_renaming)
        self.ui.le_profile_name.returnPressed.connect(self.save_profile)
        self.ui.lw_profiles.itemDoubleClicked.connect(self.apply_data)

        self.ui.instagram.clicked.connect(self.url_instagram)
        self.ui.cgcenter.clicked.connect(self.url_cgcenter)
        self.ui.artstation.clicked.connect(self.url_artstation)
        self.ui.gumroad.clicked.connect(self.url_gumroad)
        self.ui.twitter.clicked.connect(self.url_twitter)
        self.ui.facebook.clicked.connect(self.url_facebook)
        self.ui.youtube.clicked.connect(self.url_youtube)
        self.ui.telegram.clicked.connect(self.url_telegram)

        self.ui.btn_select.clicked.connect(self.select)

    # Social links
    def url_instagram(self):
        webbrowser.open("https://www.instagram.com/shirzad_bahrami/")

    def url_cgcenter(self):
        webbrowser.open("http://www.cgcenter.ir/")

    def url_artstation(self):
        webbrowser.open("https://www.artstation.com/shirzadbh")

    def url_gumroad(self):
        webbrowser.open("https://gumroad.com/cgcenter")

    def url_twitter(self):
        webbrowser.open("https://twitter.com/BahramiShirzad")

    def url_facebook(self):
        webbrowser.open("https://www.facebook.com/SH-434045970480456")

    def url_youtube(self):
        webbrowser.open("https://www.youtube.com/channel/UCXRpXukQczFrGQT9RXmgIyw?view_as=subscriber")

    def url_telegram(self):
        webbrowser.open("https://t.me/shirzadbahramiCGtutorial")

    # Add Nodes In Order
    def adding_nodes(self):

        # Find Selection as a List
        nodes = mxs.selection

        if len(nodes) > 0:

            mxs.escapeEnable = False

            self.ui.btn_add.setDisabled(True)

            group_members = []
            group_heads = []
            head_root = []
            nodes_in_chain = []
            independent_nodes = []
            result_list = []
            results_roots = []
            self.ordered_selection_list = []

            def find_group_members():
                for i in range(len(nodes)):
                    if mxs.isGroupMember(nodes[i]):
                        group_members.append(nodes[i])

            def find_group_heads():

                for i in range(len(nodes)):
                    if mxs.isGroupHead(nodes[i]):
                        group_heads.append(nodes[i])

                if len(group_heads) == 1:
                    head_root.append(group_heads[0])
                    result_list.append(group_heads[0])

                elif len(group_heads) > 1:
                    find_head_roots()

            def find_head_roots():

                for i in range(len(group_heads)):
                    if mxs.isValidNode(group_heads[i].parent) == False or mxs.isGroupMember(group_heads[i]) == False:
                        head_root.append(group_heads[i])
                        result_list.append(group_heads[i])

            def remove_group_members_from_list():
                global out_of_groups
                out_of_groups = []
                for i in range(len(nodes)): out_of_groups.append(nodes[i])
                for i in range(len(nodes)):
                    if mxs.isGroupHead(nodes[i]) or mxs.isGroupMember(nodes[i]):
                        out_of_groups.remove(nodes[i])

            def find_independent_nodes():

                for i in range(len(out_of_groups)):
                    if mxs.isValidNode(out_of_groups[i].parent) == False and out_of_groups[i].children.count == 0:
                        independent_nodes.append(nodes[i])
                        result_list.append(nodes[i])

            def find_node_in_chain():
                for i in range(len(out_of_groups)):
                    if mxs.isValidNode(out_of_groups[i].parent) == True or out_of_groups[i].children.count != 0:
                        nodes_in_chain.append(out_of_groups[i])
                        result_list.append(out_of_groups[i])

            def find_results_roots():

                for i in range(len(result_list)):
                    if mxs.isValidNode(result_list[i].parent) == False or mxs.isValidNode(result_list[i].parent) and \
                            result_list[i].parent not in result_list:
                        # print(f"#{i} - Search root", result_list[i].name)
                        results_roots.append(result_list[i])

            def put_in_ordered_list():

                for i in range(len(results_roots)):
                    self.ordered_selection_list.append(results_roots[i])
                    child_finder(results_roots[i])

            def child_finder(input):
                current = input
                count = input.children.count

                for i in range(count):

                    if current.children[i] in result_list:
                        self.ordered_selection_list.append(current.children[i])
                        # print(current.children[i].name)

                    if current.children[i].children.count != 0:
                        child_finder(current.children[i])

            def debug():
                print(f"#{len(nodes)} | All selected")
                print(f"#{len(nodes_in_chain)} | Node in Chain", nodes_in_chain)
                print(f"#{len(independent_nodes)} | Independent nodes", independent_nodes)
                print(f"#{len(out_of_groups)} | Out of Group", out_of_groups)
                print(f"#{len(group_members)} | Group members", group_members)
                print(f"#{len(group_heads)} | Group heads", group_heads)
                print(f"#{len(head_root)} | Head roots", head_root)
                print(f"#{len(result_list)} | Result", result_list)
                print(f"#{len(results_roots)} | Result roots", results_roots)
                print(f"#{len(self.ordered_selection_list)} | Result in order", self.ordered_selection_list)

            find_group_members()  # 1
            find_group_heads()  # 2
            remove_group_members_from_list()  # 3
            find_independent_nodes()  # 4
            find_node_in_chain()  # 5
            find_results_roots()  # 6
            put_in_ordered_list()  # 7

            # debug()

            # Add Result list to QListView
            self.show_nodes_in_QListView()

            self.ui.pte_reports.appendHtml(
                f'''<p><span style="color:#999999"> "{len(self.ordered_selection_list)}" items Added to selection.</span></p>''')

            mxs.escapeEnable = True

    # Cancel Rename Process
    def cancel_renaming(self):
        self.ui.btn_rename_cancel.setVisible(False)
        self.ui.le_profile_rename.setVisible(False)
        self.ui.btn_rename.setVisible(True)
        self.ui.le_profile_rename.setText('')

    # Delete Selected Profile
    def delete_profile(self):

        try:
            if self.ui.lw_profiles.count() != 0:

                # Find Selected Profile Name
                profile_name = self.ui.lw_profiles.currentItem().text()

                # Find If Selected Item Is In Data
                if profile_name in self.global_data:

                    replay = QMessageBox.question(self, 'Posture', f'Do you want to delete"{profile_name}"?',
                                                  QMessageBox.Yes | QMessageBox.No, QMessageBox.No)

                    if replay == QMessageBox.Yes:
                        self.global_data.pop(profile_name)
                        self.ui.lw_profiles.takeItem(self.ui.lw_profiles.currentRow())

                        self.ui.pte_reports.appendHtml(
                            f'''<p><span style="color:orange"> <strong>"{profile_name}" </strong> deleted from collection.</span></p>''')


                    else:
                        self.ui.pte_reports.appendHtml(
                            f'''<p><span style="color:#999999"> Cancel deleting.</span></p>''')

                else:
                    print("No Data")

        except:
            self.ui.pte_reports.appendHtml(
                f'''<p><span style="color:#999999">Choose a profile.</span></p>''')

    # Rename Selected Profile
    def rename_profile(self):

        # Find Selected Profile Is True
        if len(self.ui.lw_profiles.selectedItems()) != 0:
            self.ui.btn_rename_cancel.setVisible(True)
            self.ui.le_profile_rename.setVisible(True)
            self.ui.btn_rename.setVisible(False)

    # Rename Profile
    def rename(self):

        # Find Selected Profile Is True
        if len(
                self.ui.lw_profiles.selectedItems()) != 0 and self.ui.le_profile_rename.text() != '' and self.ui.le_profile_rename.text() not in self.global_data:
            old_name = self.ui.lw_profiles.currentItem().text()
            new_name = self.ui.le_profile_rename.text()

            self.global_data[f"{new_name}"] = self.global_data.pop(f"{old_name}")

            self.ui.le_profile_rename.setVisible(False)
            self.ui.btn_rename.setVisible(True)
            self.ui.btn_rename_cancel.setVisible(False)

            self.ui.lw_profiles.currentItem().setText(f"{new_name}")
            self.ui.le_profile_rename.setText('')

            self.ui.pte_reports.appendHtml(
                f'''<p><span style="color:#77e73a"> <strong>"{old_name}" </strong> changed to <strong>"{new_name}"</strong>.</span></p>''')

            # Def Save Profile

    # Saving objects information
    def save_profile(self):

        # Assign a name to profile
        profile_name = self.ui.le_profile_name.text()

        # Start the Process if Selection or Profile name Aren't Empty
        if profile_name != '' and profile_name not in self.global_data and self.ui.lw_selected.count() != 0:

            mxs.escapeEnable = False

            self.ui.progresss.setMaximum(len(self.ordered_selection_list))

            # Define Lists
            self.IDs = []
            self.name = []
            self.parent_IDs = []
            self.current_child_ID = []
            self.children_IDs = []
            self.color = []

            # Define Different Type of Transforms
            self.global_transform = []
            self.local_transform = []
            self.parent_transform = []

            # Define Current Profile Dictionary
            self.current_dict = {}

            # Generate Specific IDs For Entry Nodes
            for i in range(len(self.ordered_selection_list)):

                self.ui.progresss.setValue(i + 1)

                node = self.ordered_selection_list[i]
                generated_ID = uuid.uuid1()

                # Give Every Entry Node A ID Or Keep Their Old IDs
                if mxs.getAppData(node, 10) == None:

                    mxs.setAppData(node, 10, generated_ID)
                    self.IDs.append(mxs.getAppData(node, 10))
                else:

                    self.IDs.append(mxs.getAppData(node, 10))

            # Define Node Names
            for i in range(len(self.ordered_selection_list)):
                # Add Node Names To "self.name" List
                self.name.append(str(self.ordered_selection_list[i].name))

            # Define Colors
            for i in range(len(self.ordered_selection_list)):
                # Add Node Color To "self.color" List
                self.color.append(str(self.ordered_selection_list[i].wirecolor))

            # Define Parent
            for i in range(len(self.ordered_selection_list)):

                # Add Node Parents ID To "self.parent_IDs" List
                if mxs.isValidNode(self.ordered_selection_list[i].parent):

                    parent_node = self.ordered_selection_list[i].parent
                    parent_generated_id = uuid.uuid1()
                    self.parent_transform.append(str(self.ordered_selection_list[i].parent.transform))

                    if mxs.getAppData(parent_node, 10) == None:
                        mxs.setAppData(parent_node, 10, parent_generated_id)
                        self.parent_IDs.append(str(parent_generated_id))

                    else:
                        self.parent_IDs.append(str(mxs.getAppData(parent_node, 10)))

                else:
                    self.parent_transform.append(None)
                    self.parent_IDs.append(None)

            # Define Children
            for i in range(len(self.ordered_selection_list)):

                # Add Node Children IDs To "self.children_IDs" List
                if self.ordered_selection_list[i].children.count == 0:
                    self.children_IDs.append(None)

                else:
                    for item in range(self.ordered_selection_list[i].children.count):
                        curent_child = self.ordered_selection_list[i].children[item]

                        child_generated_id = uuid.uuid1()

                        if mxs.getAppData(curent_child, 10) == None:
                            mxs.setAppData(curent_child, 10, child_generated_id)
                            self.current_child_ID.append(str(mxs.getAppData(curent_child, 10)))

                        else:
                            self.current_child_ID.append(str(mxs.getAppData(curent_child, 10)))
                    self.children_IDs.append(self.current_child_ID)
                    self.current_child_ID = []

            # Export Local And Global Transform
            if self.ui.chb_global.isChecked() and self.ui.chb_local.isChecked():

                # Calculate Global Transform
                for i in range(len(self.ordered_selection_list)):
                    self.global_transform.append(str(self.ordered_selection_list[i].transform))

                self.current_dict["global_transform"] = self.global_transform

                trubled_nodes = []

                for item in range(len(self.ordered_selection_list)):
                    if mxs.isValidNode(self.ordered_selection_list[item].parent):
                        local_node = self.ordered_selection_list[item]

                        offset = mxs.inverse(local_node.parent.transform * mxs.inverse(local_node.transform))
                        self.local_transform.append(str(offset))

                    elif mxs.isValidNode(self.ordered_selection_list[item].parent) != True:
                        trubled_nodes.append(self.ordered_selection_list[item].name)
                        self.local_transform.append(None)

                self.current_dict["parent_transform"] = self.parent_transform
                self.current_dict["global_transform"] = self.global_transform
                self.current_dict["local_transform"] = self.local_transform

                self.current_dict["ID"] = self.IDs
                self.current_dict["parent_ID"] = self.parent_IDs
                self.current_dict["children_IDs"] = self.children_IDs
                self.current_dict["color"] = self.color
                self.current_dict["name"] = self.name

                if len(trubled_nodes) > 0:
                    self.ui.pte_reports.appendHtml(
                        f'''<p><span style="color:red"> <strong>Error:</strong> </span></p>''')
                    self.ui.pte_reports.appendHtml(
                        f'''<p><span style="color:orange"> Objects in the following list don't have parent: <br />Count: {len(trubled_nodes)} <br />Names: {trubled_nodes}.</span></p>''')

            # Export Global Transform
            elif self.ui.chb_global.isChecked():

                # Calculate Global Transform
                for i in range(len(self.ordered_selection_list)):
                    self.global_transform.append(str(self.ordered_selection_list[i].transform))

                self.current_dict["parent_transform"] = self.parent_transform
                self.current_dict["global_transform"] = self.global_transform

                self.current_dict["ID"] = self.IDs
                self.current_dict["parent_ID"] = self.parent_IDs
                self.current_dict["children_IDs"] = self.children_IDs
                self.current_dict["color"] = self.color
                self.current_dict["name"] = self.name

            # Export Local Transform
            elif self.ui.chb_local.isChecked():
                trubled_nodes = []

                for item in range(len(self.ordered_selection_list)):
                    if mxs.isValidNode(self.ordered_selection_list[item].parent):
                        local_node = self.ordered_selection_list[item]

                        offset = mxs.inverse(local_node.parent.transform * mxs.inverse(local_node.transform))
                        self.local_transform.append(str(offset))

                    elif mxs.isValidNode(self.ordered_selection_list[item].parent) != True:
                        trubled_nodes.append(self.ordered_selection_list[item].name)
                        self.local_transform.append(None)

                if len(trubled_nodes) > 0:
                    self.ui.pte_reports.appendHtml(
                        f'''<p><span style="color:red"> <strong>Error:</strong> </span></p>''')
                    self.ui.pte_reports.appendHtml(
                        f'''<p><span style="color:orange"> Objects in the following list don't have parent: <br />Count: {len(trubled_nodes)} <br />Names: {trubled_nodes}.</span></p>''')

                self.current_dict["parent_transform"] = self.parent_transform
                self.current_dict["local_transform"] = self.local_transform

                self.current_dict["ID"] = self.IDs
                self.current_dict["parent_ID"] = self.parent_IDs
                self.current_dict["children_IDs"] = self.children_IDs
                self.current_dict["color"] = self.color
                self.current_dict["name"] = self.name

                self.ui.progresss.setValue(0)

            self.global_data[f"{profile_name}"] = self.current_dict
            self.add_profiles_to_list(profile_name)
            self.ui.progresss.setValue(0)
            self.ui.le_profile_name.setText('')

            self.ui.pte_reports.appendHtml(
                f'''<p><span style="color:#77e73a"> <strong>"{profile_name}" </strong> added to collection.</span></p>''')
            mxs.escapeEnable = True

    # Add Profiles To QTreeVidgets
    def add_profiles_to_list(self, name):
        self.ui.lw_profiles.addItem(f"{name}")

        for i in range(self.ui.lw_profiles.count()):
            self.ui.lw_profiles.item(i).setIcon(self.profile_icon)

    # Def Clear Selection
    def clear_selection_and_node_list(self):
        if self.ui.lw_selected.count() != 0:
            num = len(self.ordered_selection_list)
            self.ordered_selection_list = []

            self.ui.btn_add.setDisabled(False)

            self.ui.pte_reports.appendHtml(
                f'''<p><span style="color:#999999">"{num}" Removed from selection.</span></p>''')

            self.ui.lw_selected.clear()
            self.ui.progress.setValue(0)

    # Show Selected Nodes in QListView
    def show_nodes_in_QListView(self):

        # Define MAximum Value Of ProgressBar
        self.ui.progress.setMaximum(len(self.ordered_selection_list))

        for i in range(len(self.ordered_selection_list)):

            self.ui.lw_selected.addItem(f"{self.ordered_selection_list[i].name}")

            if mxs.superclassof(self.ordered_selection_list[i]) == self.geometry_class:
                self.ui.lw_selected.item(i).setIcon(self.geometry_icon)

            elif mxs.superclassof(self.ordered_selection_list[i]) == self.shape_class:
                self.ui.lw_selected.item(i).setIcon(self.shape_icon)

            elif mxs.superclassof(self.ordered_selection_list[i]) == self.camera_class:
                self.ui.lw_selected.item(i).setIcon(self.camera_icon)

            elif mxs.superclassof(self.ordered_selection_list[i]) == self.helper_class:
                self.ui.lw_selected.item(i).setIcon(self.helper_icon)

            elif mxs.superclassof(self.ordered_selection_list[i]) == self.light_class:
                self.ui.lw_selected.item(i).setIcon(self.light_icon)

            elif mxs.superclassof(self.ordered_selection_list[i]) == self.spacewarp_class:
                self.ui.lw_selected.item(i).setIcon(self.spacewarp_icon)

            self.ui.progress.setValue(i + 1)

    # Def Variables
    def define_variables(self):

        # Set Deafault Path
        self.path = os.path.dirname(os.path.abspath(__file__))

        # Path for auto loading on start
        # self.default_path = None

        # Define Global Data (Dictionary)
        self.global_data = {}

        # Define Classes for Recognizing Icons
        self.geometry_class = mxs.execute("GeometryClass")
        self.shape_class = mxs.execute("shape")
        self.light_class = mxs.execute("light")
        self.camera_class = mxs.execute("camera")
        self.helper_class = mxs.execute("helper")
        self.spacewarp_class = mxs.execute("SpacewarpObject")

        # Icons are now defined in init_standard_icons() method using Qt standard icons

    # Select content
    def select(self):

        if len(self.ui.lw_profiles.selectedItems()) != 0:

            mxs.escapeEnable = False

            selected = self.ui.lw_profiles.currentItem().text()

            selection_list = []
            temporary_list = []
            for items in mxs.objects:
                if mxs.getAppData(items, 10):
                    temporary_list.append(items)

            self.ui.progresss.setMaximum(len(self.global_data[f"{selected}"]["ID"]))

            # Loop trough all IDs in Selected Profile
            for i in range(len(self.global_data[f"{selected}"]["ID"])):

                for item in temporary_list:
                    if mxs.getAppData(item, 10):
                        if mxs.getAppData(item, 10) == self.global_data[f"{selected}"]["ID"][i]:
                            selection_list.append(item)
                            temporary_list.remove(item)
                            break
                self.ui.progresss.setValue(i + 1)

            mxs.select(selection_list)
            mxs.redrawViews()
            self.ui.progresss.setValue(0)
            mxs.escapeEnable = True

    # Def Apply Values
    def apply_data(self):

        with pymxs.undo(True):

            if len(self.ui.lw_profiles.selectedItems()) != 0:

                mxs.escapeEnable = False

                start_time = time.time()

                # Find Selected Profile
                selected = self.ui.lw_profiles.currentItem().text()

                self.ui.progresss.setMaximum(len(self.global_data[f"{selected}"]["ID"]))

                holded_temporary_list = []
                temporary_list = []
                for items in mxs.objects:
                    if mxs.getAppData(items, 10):
                        temporary_list.append(items)

                parent_temporary_list = temporary_list
                children_temporary_list = temporary_list

                if self.ui.rb_global.isChecked() and self.ui.chb_realtime.isChecked():

                    try:

                        recreated_list = []

                        # Loop trough all IDs in Selected Profile
                        for i in range(len(self.global_data[f"{selected}"]["ID"])):

                            self.ui.progresss.setValue(i + 1)

                            # Detect and select node by ID
                            node_ID = self.global_data[f"{selected}"]["ID"][i]
                            node = None

                            for item in temporary_list:
                                if mxs.getAppData(item, 10):
                                    if mxs.getAppData(item, 10) == node_ID:
                                        node = item
                                        temporary_list.remove(item)
                                        break

                            # Find If Node Is Deleted Or Not
                            if mxs.isValidNode(node) != True:
                                old_node_ID = self.global_data[f"{selected}"]["ID"][i]

                                # Create New node and make it's ID
                                new_node = mxs.Point()
                                new_node_ID = self.global_data[f"{selected}"]["ID"][i]
                                mxs.setAppData(new_node, 10, new_node_ID)

                                # Apply Data To Objects
                                new_node.transform = mxs.execute(self.global_data[f"{selected}"]["global_transform"][i])
                                new_node.wirecolor = mxs.execute(self.global_data[f"{selected}"]["color"][i])

                                # new_node.name = mxs.execute(self.global_data[f"{selected}"]["name"][i])
                                new_node.name = self.global_data[f"{selected}"]["name"][i]

                                recreated_list.append(new_node.name)

                                new_node.showLinks = True
                                new_node.showLinksOnly = True

                                mxs.redrawViews()

                                # Find Objects Parent
                                if self.global_data[f"{selected}"]["parent_ID"][i] != None:

                                    try:
                                        parent_ID = self.global_data[f"{selected}"]["parent_ID"][i]
                                        parent_node = None
                                        for item in mxs.objects:
                                            if mxs.getAppData(item, 10) == parent_ID:
                                                parent_node = item
                                                break

                                        new_node.parent = parent_node
                                    except:
                                        pass

                                # Find Object Children
                                if self.global_data[f"{selected}"]["children_IDs"][i] != None:
                                    for item in self.global_data[f"{selected}"]["children_IDs"][i]:

                                        try:
                                            child_ID = item
                                            child_node = None
                                            for child_item in mxs.objects:
                                                if mxs.getAppData(child_item, 10) == child_ID:
                                                    child_node = child_item
                                                    break

                                            child_node.parent = new_node

                                        except:
                                            pass

                            else:

                                # Apply Data To Objects
                                node.transform = mxs.execute(self.global_data[f"{selected}"]["global_transform"][i])
                                # node.wirecolor = mxs.execute(self.global_data[f"{selected}"]["color"][i])
                                # node.name = mxs.execute(self.global_data[f"{selected}"]["name"][i])

                                # Give stored color for group members
                                if mxs.isGroupHead(node):
                                    if self.global_data[f"{selected}"]["color"][i] == "(color 0 0 0)":
                                        pass
                                    else:
                                        def child_finder(input):
                                            current = input
                                            count = input.children.count

                                            for items in range(count):

                                                current.children[items].wirecolor = mxs.execute(
                                                    self.global_data[f"{selected}"]["color"][i])

                                                if current.children[items].children.count != 0:
                                                    child_finder(current.children[items])

                                        child_finder(node)
                                else:
                                    node.wirecolor = mxs.execute(self.global_data[f"{selected}"]["color"][i])

                                mxs.redrawViews()

                        mxs.redrawViews()

                        if len(recreated_list) > 0:
                            self.ui.pte_reports.appendHtml(
                                f'''<p><span style="color:#999999">"Object in the following list are recreated: <br>"{recreated_list}"</span></p>''')
                        self.ui.pte_reports.appendHtml(
                            f'''<p><span style="color:#77e73a">Global profile: <strong>"{selected}"</strong> applied to scene in <strong>"{round(((time.time() - start_time)), 2)}"</strong> Seconds .</span></p>''')

                    except:
                        self.ui.pte_reports.appendHtml(
                            f'''<p><span style="color:red"> <strong>Error:</strong> </span></p>''')
                        self.ui.pte_reports.appendHtml(
                            f'''<p><span style="color:orange">Selected profile <strong>"{selected}"</strong> does not have "Global" data.</span></p>''')

                elif self.ui.rb_local.isChecked() and self.ui.chb_realtime.isChecked():

                    try:
                        recreated_list = []

                        # Loop trough all IDs in Selected Profile
                        for i in range(len(self.global_data[f"{selected}"]["ID"])):

                            self.ui.progresss.setValue(i + 1)

                            # Detect and select node by ID
                            node_ID = self.global_data[f"{selected}"]["ID"][i]
                            node = None
                            for item in temporary_list:
                                if mxs.getAppData(item, 10):
                                    if mxs.getAppData(item, 10) == node_ID:
                                        node = item
                                        temporary_list.remove(item)
                                        break

                            # Find If Node Is Deleted Or Not
                            if mxs.isValidNode(node) != True:
                                old_node_ID = self.global_data[f"{selected}"]["ID"][i]

                                # Create New node and make it's ID
                                new_node = mxs.Point()
                                new_node_ID = self.global_data[f"{selected}"]["ID"][i]
                                mxs.setAppData(new_node, 10, new_node_ID)

                                recreated_list.append(new_node.name)

                                # Find Objects Parent
                                if self.global_data[f"{selected}"]["parent_ID"][i] != None:

                                    try:
                                        parent_ID = self.global_data[f"{selected}"]["parent_ID"][i]
                                        parent_node = None
                                        for item in mxs.objects:
                                            if mxs.getAppData(item, 10) == parent_ID:
                                                parent_node = item
                                                break

                                        new_node.parent = parent_node
                                    except:
                                        pass

                                # Find Object Children
                                if self.global_data[f"{selected}"]["children_IDs"][i] != None:
                                    for item in self.global_data[f"{selected}"]["children_IDs"][i]:

                                        try:
                                            child_ID = item
                                            child_node = None
                                            for child_item in mxs.objects:
                                                if mxs.getAppData(child_item, 10) == child_ID:
                                                    child_node = child_item
                                                    break

                                            child_node.parent = new_node

                                        except:
                                            pass

                                # Apply Data To Objects
                                new_node.transform = mxs.execute(
                                    self.global_data[f"{selected}"]["local_transform"][i]) * parent_node.transform
                                new_node.wirecolor = mxs.execute(self.global_data[f"{selected}"]["color"][i])
                                new_node.name = self.global_data[f"{selected}"]["name"][i]

                                new_node.showLinks = True
                                new_node.showLinksOnly = True

                                mxs.redrawViews()

                            else:

                                node.transform = mxs.execute(
                                    self.global_data[f"{selected}"]["local_transform"][i]) * node.parent.transform
                                # node.wirecolor = mxs.execute(self.global_data[f"{selected}"]["color"][i])
                                # node.name = mxs.execute(self.global_data[f"{selected}"]["name"][i])

                                # Give stored color for group members
                                if mxs.isGroupHead(node):
                                    if self.global_data[f"{selected}"]["color"][i] == "(color 0 0 0)":
                                        pass
                                    else:
                                        def child_finder(input):
                                            current = input
                                            count = input.children.count

                                            for items in range(count):

                                                current.children[items].wirecolor = mxs.execute(
                                                    self.global_data[f"{selected}"]["color"][i])

                                                if current.children[items].children.count != 0:
                                                    child_finder(current.children[items])

                                        child_finder(node)
                                else:
                                    node.wirecolor = mxs.execute(self.global_data[f"{selected}"]["color"][i])

                                mxs.redrawViews()

                        mxs.redrawViews()

                        if len(recreated_list) > 0:
                            self.ui.pte_reports.appendHtml(
                                f'''<p><span style="color:#999999">"Object in the following list are recreated: <br>"{recreated_list}"</span></p>''')

                        self.ui.pte_reports.appendHtml(
                            f'''<p><span style="color:#77e73a">Local profile: <strong>"{selected}"</strong> applied to scene in <strong>"{round(((time.time() - start_time)), 2)}"</strong> Seconds .</span></p>''')

                    except:
                        self.ui.pte_reports.appendHtml(
                            f'''<p><span style="color:red"> <strong>Error:</strong> </span></p>''')
                        self.ui.pte_reports.appendHtml(
                            f'''<p><span style="color:orange">Selected profile <strong>"{selected}"</strong> does not have "Local" data.</span></p>''')

                elif self.ui.rb_global.isChecked():

                    try:
                        mxs.DisableSceneRedraw()

                        recreated_list = []

                        # Loop trough all IDs in Selected Profile
                        for i in range(len(self.global_data[f"{selected}"]["ID"])):

                            self.ui.progresss.setValue(i + 1)

                            # Detect and select node by ID
                            node_ID = self.global_data[f"{selected}"]["ID"][i]
                            node = None

                            for item in temporary_list:
                                if mxs.getAppData(item, 10):
                                    if mxs.getAppData(item, 10) == node_ID:
                                        node = item
                                        temporary_list.remove(item)
                                        break

                            # Find If Node Is Deleted Or Not
                            if mxs.isValidNode(node) != True:
                                old_node_ID = self.global_data[f"{selected}"]["ID"][i]

                                # Create New node and make it's ID
                                new_node = mxs.Point()
                                new_node_ID = self.global_data[f"{selected}"]["ID"][i]
                                mxs.setAppData(new_node, 10, new_node_ID)

                                # Apply Data To Objects
                                new_node.transform = mxs.execute(self.global_data[f"{selected}"]["global_transform"][i])
                                new_node.wirecolor = mxs.execute(self.global_data[f"{selected}"]["color"][i])
                                new_node.name = self.global_data[f"{selected}"]["name"][i]

                                new_node.showLinks = True
                                new_node.showLinksOnly = True

                                recreated_list.append(new_node.name)

                                # Find Objects Parent
                                if self.global_data[f"{selected}"]["parent_ID"][i] != None:

                                    try:
                                        parent_ID = self.global_data[f"{selected}"]["parent_ID"][i]
                                        parent_node = None
                                        for item in mxs.objects:
                                            if mxs.getAppData(item, 10) == parent_ID:
                                                parent_node = item
                                                break

                                        new_node.parent = parent_node
                                    except:
                                        pass

                                # Find Object Children
                                if self.global_data[f"{selected}"]["children_IDs"][i] != None:
                                    for item in self.global_data[f"{selected}"]["children_IDs"][i]:

                                        try:
                                            child_ID = item
                                            child_node = None
                                            for child_item in mxs.objects:
                                                if mxs.getAppData(child_item, 10) == child_ID:
                                                    child_node = child_item
                                                    break

                                            child_node.parent = new_node

                                        except:
                                            pass

                            else:

                                # Apply Data To Objects
                                node.transform = mxs.execute(self.global_data[f"{selected}"]["global_transform"][i])
                                # node.wirecolor = mxs.execute(self.global_data[f"{selected}"]["color"][i])
                                # node.name = mxs.execute(self.global_data[f"{selected}"]["name"][i])

                                # Give stored color for group members
                                if mxs.isGroupHead(node):
                                    if self.global_data[f"{selected}"]["color"][i] == "(color 0 0 0)":
                                        pass
                                    else:
                                        def child_finder(input):
                                            current = input
                                            count = input.children.count

                                            for items in range(count):

                                                current.children[items].wirecolor = mxs.execute(
                                                    self.global_data[f"{selected}"]["color"][i])

                                                if current.children[items].children.count != 0:
                                                    child_finder(current.children[items])

                                        child_finder(node)
                                else:
                                    node.wirecolor = mxs.execute(self.global_data[f"{selected}"]["color"][i])

                        mxs.enableSceneRedraw()
                        mxs.redrawViews()

                        if len(recreated_list) > 0:
                            self.ui.pte_reports.appendHtml(
                                f'''<p><span style="color:#999999">"Object in the following list are recreated: <br>"{recreated_list}"</span></p>''')
                        self.ui.pte_reports.appendHtml(
                            f'''<p><span style="color:#77e73a">Global profile: <strong>"{selected}"</strong> applied to scene in <strong>"{round(((time.time() - start_time)), 2)}"</strong> Seconds .</span></p>''')


                    except:
                        self.ui.pte_reports.appendHtml(
                            f'''<p><span style="color:red"> <strong>Error:</strong> </span></p>''')
                        self.ui.pte_reports.appendHtml(
                            f'''<p><span style="color:orange">Selected profile <strong>"{selected}"</strong> does not have "Global" data.</span></p>''')

                elif self.ui.rb_local.isChecked():

                    try:
                        mxs.DisableSceneRedraw()
                        recreated_list = []

                        # Loop trough all IDs in Selected Profile
                        for i in range(len(self.global_data[f"{selected}"]["ID"])):

                            self.ui.progresss.setValue(i + 1)

                            # Detect and select node by ID
                            node_ID = self.global_data[f"{selected}"]["ID"][i]
                            node = None
                            for item in temporary_list:
                                if mxs.getAppData(item, 10):
                                    if mxs.getAppData(item, 10) == node_ID:
                                        node = item
                                        temporary_list.remove(item)
                                        break

                            # Find If Node Is Deleted Or Not
                            if mxs.isValidNode(node) != True:
                                old_node_ID = self.global_data[f"{selected}"]["ID"][i]

                                # Create New node and make it's ID
                                new_node = mxs.Point()
                                new_node_ID = self.global_data[f"{selected}"]["ID"][i]
                                mxs.setAppData(new_node, 10, new_node_ID)

                                new_node.showLinks = True
                                new_node.showLinksOnly = True

                                recreated_list.append(new_node.name)

                                # Find Objects Parent
                                if self.global_data[f"{selected}"]["parent_ID"][i] != None:

                                    try:
                                        parent_ID = self.global_data[f"{selected}"]["parent_ID"][i]
                                        parent_node = None
                                        for item in mxs.objects:
                                            if mxs.getAppData(item, 10) == parent_ID:
                                                parent_node = item
                                                break

                                        new_node.parent = parent_node
                                    except:
                                        pass

                                # Find Object Children
                                if self.global_data[f"{selected}"]["children_IDs"][i] != None:
                                    for item in self.global_data[f"{selected}"]["children_IDs"][i]:

                                        try:
                                            child_ID = item
                                            child_node = None
                                            for child_item in mxs.objects:
                                                if mxs.getAppData(child_item, 10) == child_ID:
                                                    child_node = child_item
                                                    break

                                            child_node.parent = new_node

                                        except:
                                            pass

                                # Apply Data To Objects
                                new_node.transform = mxs.execute(
                                    self.global_data[f"{selected}"]["local_transform"][i]) * parent_node.transform
                                new_node.wirecolor = mxs.execute(self.global_data[f"{selected}"]["color"][i])
                                new_node.name = self.global_data[f"{selected}"]["name"][i]

                            else:

                                node.transform = mxs.execute(
                                    self.global_data[f"{selected}"]["local_transform"][i]) * node.parent.transform
                                # node.wirecolor = mxs.execute(self.global_data[f"{selected}"]["color"][i])
                                # node.name = mxs.execute(self.global_data[f"{selected}"]["name"][i])

                                # Give stored color for group members
                                if mxs.isGroupHead(node):
                                    if self.global_data[f"{selected}"]["color"][i] == "(color 0 0 0)":
                                        pass
                                    else:
                                        def child_finder(input):
                                            current = input
                                            count = input.children.count

                                            for items in range(count):

                                                current.children[items].wirecolor = mxs.execute(
                                                    self.global_data[f"{selected}"]["color"][i])

                                                if current.children[items].children.count != 0:
                                                    child_finder(current.children[items])

                                        child_finder(node)
                                else:
                                    node.wirecolor = mxs.execute(self.global_data[f"{selected}"]["color"][i])

                        mxs.enableSceneRedraw()
                        mxs.redrawViews()

                        if len(recreated_list) > 0:
                            self.ui.pte_reports.appendHtml(
                                f'''<p><span style="color:#999999">"Object in the following list are recreated: <br>"{recreated_list}"</span></p>''')

                        self.ui.pte_reports.appendHtml(
                            f'''<p><span style="color:#77e73a">Local profile: <strong>"{selected}" </strong> applied to scene in <strong>"{round(((time.time() - start_time)), 2)}"</strong> Seconds .</span></p>''')


                    except:
                        self.ui.pte_reports.appendHtml(
                            f'''<p><span style="color:red"> <strong>Error:</strong> </span></p>''')
                        self.ui.pte_reports.appendHtml(
                            f'''<p><span style="color:orange">Selected profile <strong>"{selected}"</strong> does not have "Local" data.</span></p>''')

                self.ui.progresss.setValue(0)
                mxs.enableSceneRedraw()
                mxs.redrawViews()
                mxs.escapeEnable = True

    # Def Assign User-Interface
    def init_UI(self):
        ui_file = QFile(
            os.path.join(self.dir, 'Posture', 'Contents', 'interface', 'interface.ui'))

        ui_file.open(QFile.ReadOnly)
        self.ui = QUiLoader().load(ui_file, self)
        ui_file.close()


# Execute Posture
def execute():
    posture = PostureDialog(GetQMaxMainWindow())
    posture.show()


execute()
